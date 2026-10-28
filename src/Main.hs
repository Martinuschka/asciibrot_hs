{-# LANGUAGE BangPatterns #-}
module Main where

import Control.Concurrent (threadDelay)
import Control.Exception (SomeException, catch, fromException, AsyncException(UserInterrupt))
import Data.Char (toLower)
import Data.Complex (Complex(..), magnitude)
import System.IO (hFlush, stdout, BufferMode(..), hSetBuffering)
import Text.Read (readMaybe)

-- Configuration
width :: Int
width = 80

height :: Int
height = 40

maxIterations :: Int
maxIterations = 100

-- Character set for ASCII art (darker to brighter)
asciiChars :: String
asciiChars = " .,:;+*?%S#@"

-- Clear the console screen
clearScreen :: IO ()
clearScreen = putStr "\ESC[2J\ESC[H"

-- Hide cursor
hideCursor :: IO ()
hideCursor = putStr "\ESC[?25l"

-- Show cursor
showCursor :: IO ()
showCursor = putStr "\ESC[?25h"

-- Mandelbrot calculation
mandelbrot :: Complex Double -> Int
mandelbrot c = go (0 :+ 0) 0
  where
    go !z !n
      | magnitude z > 2.0 = n
      | n >= maxIterations = n
      | otherwise = go (z * z + c) (n + 1)

-- Map iteration count to ASCII character
iterToChar :: Int -> Char
iterToChar n = asciiChars `index` charIndex
  where
    charIndex = floor (fromIntegral n / fromIntegral maxIterations * fromIntegral (length asciiChars - 1) :: Double) :: Int
    index xs i = if i >= 0 && i < length xs then xs !! i else last xs

-- Generate a single frame of the Mandelbrot set
generateFrame :: Double -> Double -> Double -> String
generateFrame zoom centerX centerY = concat [row y | y <- [0..height-1]]
  where
    viewWidth = 3.5
    viewHeight = 2.0
    row y = [iterToChar (mandelbrot (xVal x :+ yVal)) | x <- [0..width-1]] ++ "\n"
      where
        yVal = -viewHeight / 2 / zoom + centerY + (viewHeight / zoom) * fromIntegral y / fromIntegral (height - 1)
        xVal x = -viewWidth / 2 / zoom + centerX + (viewWidth / zoom) * fromIntegral x / fromIntegral (width - 1)

-- Display a frame
displayFrame :: Double -> Double -> Double -> IO ()
displayFrame zoom centerX centerY = do
  clearScreen
  hideCursor
  putStr $ generateFrame zoom centerX centerY
  showCursor

-- Run animation with given rate (frames per second)
runAnimation :: Double -> IO ()
runAnimation fps = do
  let startZoom = 1.0
      centerX = -0.743643887037151  -- Deep zoom starting point
      centerY = 0.131825904205330
      zoomFactor = 1.05  -- 5% zoom per frame
      frameDelay = floor (1000000 / fps)  -- microseconds
  
  let loop !zoom !cx !cy = do
        displayFrame zoom cx cy
        threadDelay frameDelay
        loop (zoom * zoomFactor) cx cy
  
  loop startZoom centerX centerY

-- Prompt user for frame rate
promptRate :: IO (Maybe Double)
promptRate = do
  putStr "\nEnter frame rate (frames per second, e.g., 5 or 10) or 'q' to quit: "
  hFlush stdout
  line <- getLine
  case map toLower line of
    "q" -> return Nothing
    "quit" -> return Nothing
    "exit" -> return Nothing
    _ -> case readMaybe line of
      Just rate | rate > 0 -> return (Just rate)
      _ -> do
        putStrLn "Invalid input. Please enter a positive number or 'q' to quit."
        promptRate

-- Main loop
mainLoop :: IO ()
mainLoop = do
  clearScreen
  showCursor
  putStrLn "ASCII Mandelbrot Fractal Zoom"
  putStrLn "================================"
  putStrLn "Watch the Mandelbrot set zoom in continuously!"
  putStrLn "Press Ctrl+C to interrupt and return to menu."
  putStrLn ""
  
  mRate <- promptRate
  
  case mRate of
    Nothing -> putStrLn "Goodbye!"
    Just rate -> do
      -- Run animation, catch any interrupt
      (runAnimation rate) `catch` handleInterrupt
      mainLoop
  where
    handleInterrupt :: SomeException -> IO ()
    handleInterrupt e = do
      showCursor
      putStr "\n\n"
      case fromException e of
        Just UserInterrupt -> putStrLn "Interrupted by user."
        _ -> putStrLn $ "Error: " ++ show e
      putStrLn "Returning to menu..."
      threadDelay 1000000 -- 1 second pause

-- Main entry point
main :: IO ()
main = do
  hSetBuffering stdout NoBuffering
  mainLoop
