module Main (main) where
import Test.Hspec

import UserCode

main :: IO ()
main = hspec $ do
    describe "Try" $ do
        it "read the " $ do
            myid `shouldBe` "42"
