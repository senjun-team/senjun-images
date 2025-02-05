{- 
Simple wrapper, that make output more parsable
-}
module MachineFormatter (
    formatter
) where

import Test.Hspec.Api.Format.V2

import Data.List (intercalate)

import Control.Monad (unless)

formatOnlyFalsy :: Format
formatOnlyFalsy event = case event of
  ItemDone path item -> unless (isSuccess item) $ putStrLn (formatItem path item) 
  _ -> return ()

formatter :: (String, FormatConfig -> IO Format)
formatter = ("machine", \ _config -> return formatOnlyFalsy)

formatItem :: Path -> Item -> String
formatItem path item = joinPath path <> formatResult item

formatResult :: Item -> String
formatResult item = case itemResult item of
  Success {} -> ""
  Pending {} -> "-"
  Failure _ reason -> case reason of
                            ExpectedButGot _ b c -> "\n? " ++ b ++ "\n- " ++ c ++ "\n"
                            Reason r -> "\n" ++ r
                            ColorizedReason r -> "\n" ++ r
                            r -> "\n" ++ show r

joinPath :: Path -> String
joinPath (groups, requirement) = intercalate "." $ groups ++ [requirement]

isSuccess ::  Item -> Bool
isSuccess item = case itemResult item of
        Success -> True
        _ -> False
