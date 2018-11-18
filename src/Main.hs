{-# LANGUAGE OverloadedStrings #-}

-- license MIT https://raw.githubusercontent.com/fromjavatohaskell/parse-sessionstore/master/LICENSE

module Main where

import           Data.Aeson
import           Data.Aeson.Types
import qualified Data.Foldable        as F
import qualified Data.ByteString.Lazy as LB
import qualified Data.Text            as T
import qualified Data.Text.IO         as T
import qualified System.IO            as IO

getUrlAndTitle :: Value -> Parser [T.Text]
getUrlAndTitle = withObject "urlAndTitle" $ \o -> do
  url   <- o .: "url"
  title <- o .: "title"
  return [url <> " => " <> title]

entries :: (Value -> Parser [a]) -> Value -> Parser [a]
entries f = withArray "entries" $ \arr -> concat <$> traverse f arr

field :: FromJSON a => T.Text -> (a -> Parser b) -> Value -> Parser b
field key f = withObject (T.unpack key) $ \o -> (o .: key) >>= f

extractData :: Value -> Parser [T.Text]
extractData = f "windows" $ e $ f "tabs" $ e $ f "entries" $ e $ getUrlAndTitle
  where f = field; e = entries

-- LB.hGetContents IO.stdin :: IO LB.ByteString
-- decode :: LB.ByteString -> Maybe Value
-- parseMaybe extractData :: Value -> Maybe [T.Text]
-- T.putStrLn :: T.Text -> IO ()

main :: IO ()
main = do
  contents <- LB.getContents
  case decode contents >>= parseMaybe extractData of
    Just list -> F.traverse_ T.putStrLn list
    Nothing -> T.hPutStrLn IO.stderr "error parsing session store"

