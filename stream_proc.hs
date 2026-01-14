module DataStream where

import Data.Bits
import Data.Word
import Control.Concurrent
import Control.Monad

type Stream = [Word8]

transform :: Stream -> Word32 -> Stream
transform [] _ = []
transform (x:xs) seed = 
    let newX = x `xor` fromIntegral (seed .&. 0xFF)
        newSeed = (seed * 1103515245 + 12345) .&. 0x7FFFFFFF
    in rotateL newX 3 : transform xs newSeed

processPackets :: Int -> IO ()
processPackets n = replicateM_ n $ do
    putStrLn "Processing stream cluster..."
    threadDelay 1000000

main :: IO ()
main = do
    let raw = [0x41, 0x42, 0x43, 0x44]
    let result = transform raw 0x1337
    print result
