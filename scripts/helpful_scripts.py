from brownie import network, config, accounts, MockV3Aggregator, FundMe
from web3 import Web3
import os

FORKED_LOCAL_ENVIROMENTS = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
# aggiungiamo il fork alla nostra lista network di brownie
# brownie networks add development mainnet-fork-dev cmd=ganace-cli host=http://127.0.0.1 fork='https://mainnet.infura.io/v3/$WEB3_INFURA_PROJECT_ID' accounts=10 mnemonic=brownie port=7545
# password per alchemy: "suffisso"alchemy
# brownie networks add development mainnet-fork-dev-1 cmd=ganace-cli host=http://127.0.0.1 fork=https://eth-mainnet.alchemyapi.io/v2/n8LdfT7aThMXbxO0cvPuUYSvV8biHQTk accounts=10 mnemonic=brownie port=7545


DECIMALS = 8
STARTING_PRICE = 200000000000


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIROMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(os.getenv("PRIVATE_KEY"))


def deploy_mocks():
    print(f"The active network is{network.show_active()}")
    print("Deploy Mocks...")
    if len(MockV3Aggregator) <= 0:
        # la funzione toWei aggiunge l'unità di misura usanodo ether aggiungerà 18 0 dopo il numero scelto
        MockV3Aggregator.deploy(
            # DECIMALS, Web3.toWei(STARTING_PRICE, "ether"), {"from": get_account()}
            DECIMALS,
            STARTING_PRICE,
            {"from": get_account()},
        )

    print("Mock Deployed!")
    price_feed_address = MockV3Aggregator[-1].address

    # per aggiungere ujn network a brownie (es. polygon avalanche cronos etc.)
    # digitare nella console brownie networks add la chain(es. Ethereum) il nome(es. Test-Ethereum) l'host (es.http://etc.) e il chainid(es. 1337)
    # es. brownie networks add Ethereum ganache-local host=http://127.0.0.1:7545 chainid=1337
