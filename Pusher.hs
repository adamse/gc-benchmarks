{-# LANGUAGE ViewPatterns #-}
module Main (main) where

import qualified Control.Exception as Exception
import qualified Control.Monad as Monad
import qualified Data.ByteString as ByteString
import qualified Data.Map.Strict as Map
import System.Environment

data Msg = Msg !Int !ByteString.ByteString

type Chan = Map.Map Int ByteString.ByteString

message :: Int -> Msg
message n = Msg n (ByteString.replicate 1024 (fromIntegral n))

pushMsg :: Int -> Chan -> Msg -> IO Chan
pushMsg n chan (Msg msgId msgContent) =
  Exception.evaluate $
    let
      inserted = Map.insert msgId msgContent chan
    in
      if n < Map.size inserted
      then Map.deleteMin inserted
      else inserted

main :: IO ()
main = do
  [read -> n] <- getArgs
  Monad.foldM_ (pushMsg n) Map.empty (map message [1..n*5])
