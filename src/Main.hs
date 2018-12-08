{-# LANGUAGE OverloadedStrings #-}

-- license MIT https://raw.githubusercontent.com/fromjavatohaskell/parse-sessionstore/master/LICENSE-MIT

module Main where

import           Control.Monad (void)
import           Data.Aeson (Value, FromJSON, decode, withObject, withArray, (.:))
import           Data.Aeson.Types (Parser, parseMaybe)
import qualified Data.ByteString.Lazy as LB
import           Data.Text (Text)
import qualified Data.Text            as T
import qualified Data.Text.IO         as T
import qualified System.IO            as IO

getUrlAndTitle :: Value -> Parser [Text]
getUrlAndTitle = withObject "urlAndTitle" $ \o -> do
  url   <- o .: "url"
  title <- o .: "title"
  return [url <> " => " <> title]

entries :: (Value -> Parser [a]) -> Value -> Parser [a]
entries f = withArray "entries" $ \arr -> concat <$> traverse f arr

field :: FromJSON a => Text -> (a -> Parser b) -> Value -> Parser b
field key f = withObject (T.unpack key) $ \o -> (o .: key) >>= f

extractData :: Value -> Parser [Text]
extractData = f "windows" $ e $ f "tabs" $ e $ f "entries" $ e $ getUrlAndTitle
  where f = field; e = entries

-- decode :: LB.ByteString -> Maybe Value
-- parseMaybe extractData :: Value -> Maybe [Text]

main :: IO ()
main = do
  contents <- LB.getContents
  case decode contents >>= parseMaybe extractData of
    Just list -> void $ traverse T.putStrLn list
    Nothing -> T.hPutStrLn IO.stderr "error parsing session store"

