{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}

-- |
-- Module: Main
-- Copyright: Copyright © 2018 Kadena LLC.
-- License: MIT
-- Maintainer: Lars Kuhtz <lars@kadena.io>
-- Stability: experimental
--
-- Chainweb Test Suite
--

module Main ( main ) where


import Test.Tasty
import Test.Tasty.QuickCheck

-- internal modules

import qualified Chainweb.Cut (properties)
import qualified Chainweb.Difficulty (properties)
import qualified Chainweb.HostAddress (properties)
import qualified Chainweb.Sync.WebBlockHeaderStore.Test (properties)
import qualified Chainweb.Test.BlockHeader.Genesis
import qualified Chainweb.Test.BlockHeaderDB
import qualified Chainweb.Test.CoinContract
import qualified Chainweb.Test.DiGraph
import qualified Chainweb.Test.Mempool.InMem
import qualified Chainweb.Test.Mempool.RestAPI
import qualified Chainweb.Test.Mempool.Socket
import qualified Chainweb.Test.Mempool.Sync
import qualified Chainweb.Test.Pact.Checkpointer
import qualified Chainweb.Test.Pact.PactExec
import qualified Chainweb.Test.Pact.PactInProcApi
import qualified Chainweb.Test.Pact.SPV
import qualified Chainweb.Test.RestAPI
import qualified Chainweb.Test.Roundtrips
import qualified Chainweb.Test.SPV
import qualified Chainweb.Test.Store.CAS.FS
import qualified Chainweb.Test.Store.Git
import qualified Chainweb.Test.TreeDB.Persistence
import qualified Chainweb.Test.TreeDB.RemoteDB
import qualified Chainweb.Test.TreeDB.Sync
import Chainweb.Test.Utils (RunStyle(..), ScheduledTest, schedule, testGroupSch)
import qualified Chainweb.TreeDB (properties)
import qualified Chainweb.Utils.Paging (properties)

import qualified Data.DiGraph (properties)
import qualified Data.PQueue.Test (properties)
import qualified Data.Word.Encoding (properties)

import qualified P2P.Node.PeerDB (properties)
import qualified P2P.TaskQueue.Test (properties)

main :: IO ()
main = do
  pactSuite <- pactTestSuite -- Tasty.Golden tests nudge this towards being an IO result
  let allTests = testGroup "Chainweb Tests"
        . schedule Sequential
        $ pactSuite : suite
  defaultMain allTests

pactTestSuite :: IO ScheduledTest
pactTestSuite = do
    pactTests <- Chainweb.Test.Pact.PactExec.tests
    pactInProcApiTests <- Chainweb.Test.Pact.PactInProcApi.tests
    pure $ testGroupSch "Chainweb-Pact Tests"
        [ pactTests
        , pactInProcApiTests
        , Chainweb.Test.Pact.Checkpointer.tests
        , Chainweb.Test.Pact.SPV.tests
        ]

suite :: [ScheduledTest]
suite =
    [ testGroupSch "Chainweb Unit Tests"
        [ testGroup "BlockHeaderDb"
            [ Chainweb.Test.BlockHeaderDB.tests
            , Chainweb.Test.TreeDB.RemoteDB.tests
            , Chainweb.Test.TreeDB.Persistence.tests
            , Chainweb.Test.TreeDB.Sync.tests
            , testProperties "Chainweb.TreeDB" Chainweb.TreeDB.properties
            ]
        , Chainweb.Test.CoinContract.tests
        , Chainweb.Test.Store.CAS.FS.tests
        , Chainweb.Test.Store.Git.tests
        , Chainweb.Test.Roundtrips.tests
        , Chainweb.Test.RestAPI.tests
        , Chainweb.Test.DiGraph.tests
        , Chainweb.Test.SPV.tests
        , Chainweb.Test.Mempool.InMem.tests
        , Chainweb.Test.Mempool.Socket.tests
        , Chainweb.Test.Mempool.Sync.tests
        , Chainweb.Test.Mempool.RestAPI.tests
        , Chainweb.Test.BlockHeader.Genesis.tests
        , testProperties "Chainweb.BlockHeaderDb.RestAPI.Server" Chainweb.Utils.Paging.properties
        , testProperties "Chainweb.HostAddress" Chainweb.HostAddress.properties
        , testProperties "Chainweb.Sync.WebBlockHeaderStore.Test" Chainweb.Sync.WebBlockHeaderStore.Test.properties
        , testProperties "P2P.Node.PeerDB" P2P.Node.PeerDB.properties
        , testProperties "P2P.TaskQueue.Test" P2P.TaskQueue.Test.properties
        , testProperties "Data.DiGraph" Data.DiGraph.properties
        , testProperties "Data.PQueue.Test" Data.PQueue.Test.properties
        , testProperties "Chainweb.Difficulty" Chainweb.Difficulty.properties
        , testProperties "Data.Word.Encoding" Data.Word.Encoding.properties
        , testProperties "Chainweb.Cut" Chainweb.Cut.properties
        ]
    ]
