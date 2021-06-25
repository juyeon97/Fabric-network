#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
CHANNEL_NAME=mychannel

# remove previous crypto material and config transactions
rm -fr config/*
rm -fr crypto-config/*

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then #0이 아니면 오류. 대괄호 사이에 빈칸 필수.
  echo "Failed to generate crypto material..."
  exit 1
fi

rm -rf config #일단 지움. 원래 if문으로 만약 있으면~ 없으면 ~ 이렇게 해야함./ 영리한 config 디렉토리 관리 쉘스크립트 추가하기.
mkdir config

# generate genesis block for orderer
configtxgen -profile ThreeOrgOrdererGenesis -outputBlock ./config/genesis.block #configtxgen 유틸리티 사용 (bin폴더에 있는).  configtx.yaml가 생략되어있는데 8번째 줄에 환경변수로 설장되어있어서. (이부분 잘 이해 안됨. 근데 하이퍼레저에서 중요한거라고함...)
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

# generate channel configuration transaction
configtxgen -profile ThreeOrgChannel -outputCreateChannelTx ./config/channel.tx -channelID $CHANNEL_NAME #channel.tx라는 이름으로 만들어내라. 이때 채널 아이디는 CHANNEL_NAME으로
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

# generate anchor peer transaction
configtxgen -profile ThreeOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP #앵커피어는 각각 org마다 생겨야함.우리는 3개로 설정했으니까 
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi

configtxgen -profile ThreeOrgChannel -outputAnchorPeersUpdate ./config/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP #앵커피어는 각각 org마다 생겨야함.우리는 3개로 설정했으니까 
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org2MSP..."
  exit 1
fi
configtxgen -profile ThreeOrgChannel -outputAnchorPeersUpdate ./config/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP #앵커피어는 각각 org마다 생겨야함.우리는 3개로 설정했으니까 
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org3MSP..."
  exit 1
fi