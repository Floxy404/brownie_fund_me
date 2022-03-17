// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
/*
interface 
le interfaccie si usano al posto dei contratti 
pero le interfacce non hanno implementazione completa delle funzioni hanno solo il 
nome della funzione e il comando returns quello che fanno è dire a solidity quali funzioni possono 
interagire con il nostro contratto cosi da poter chiamare tali funzioni da altri contratti 
riescono a fare cio poichè le interfacce compilano fino all'ABI che è quello che parla con solidity 
permettendogli di chiamare altre funzioni da contratti
OGNI VOLTA CHE VUOI INTERAGIRE CON UN CONTRATTO CHE è GIA STATO DEPLOIED TI SERVE L'ABI DEL SUDDETTO CONTRATTO
*/
// brownie non è in grado di importare file da npm (come remix) pero è in grado di scaricarli da git hub
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

/*
interface AggregatorV3Interface {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}
*/
contract FundMe {
    // quello che facciamo using è attaccare la libreria di safemath al type uint256 così facendo
    // ogni volta che usiamo uint256 il sistema usera la libreria safemath per controllare che non ci sia stack overflow
    // questa va usato per ogni versione di soliditi sotto la 0.8.0 poichè da questa versione in poi solidity controlla da sola l'overflow
    using SafeMathChainlink for uint256;
    address payable public owner;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10**18;
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "you need at least 50 USD worth of ETH"
        );
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);

        // come convertire il valore in ether a quello in usd
        // prima devo conoscere il rateo di conversione
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // una tuple è una lista di oggetti potenzialmente di diversi tipi il cui numero è una costante al momento della compilazione
        // questa qua sotto è una sintassi per avere una tuple anche se in questo caso il compilatore ci da il warning
        // poichè non usiamo tutte le variabili all'interno della tuple
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        //non si puo solo scrivere return answer perchè i due tipi non combaciano (uno è int l'altro è uint)
        // quindi usiamo un type casting che vuol dire avvolgere un tipo con un altro che vogliamo
        // ricorda si puo moltiplicare il valore *10000000000 per ottenere avere il prezzo in wei
        return uint256(answer * 10000000000);
    }

    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        // 1000000000000000000
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 100000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // minimumUSD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return ((minimumUSD * precision) / price) + 1;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() public payable onlyOwner {
        // this si riferisce al contratto al quale sei all'interno quindi adress di questo contratto
        owner.transfer(address(this).balance);
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
