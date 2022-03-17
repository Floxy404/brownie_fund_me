from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)


# quando si vuole lavorare con chain chiuse come ganache e si sta costruendo contratti che utilizzano gli oracoli
# per cui si creano dei contratti fasulli (mock contracts) che replicano l'oracolo con un prezzo fisso di un asset
def deploy_Fund_me():
    account = get_account()
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        price_feed_address = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deploy_mocks()
        price_feed_address = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"contract deployed to {fund_me.address}")
    return fund_me

# fare un fork della mainnet è un ottimo modo per testare il nostro contratto poichè il fork è esattamente uguale alla mainnet esistente
# permettendoci così di vedere come il nostro contratto interagirà con l'enviroment
def main():
    deploy_Fund_me()


# per aggiungere ujn network a brownie (es. polygon avalanche cronos etc.)
# digitare nella console brownie networks add la chain(es. Ethereum) il nome(es. Test-Ethereum) l'host (es.http://etc.) e il chainid(es. 1337)
# es. Ethereum ganache-local host=http://127.0.0.1:7545 chainid=1337
