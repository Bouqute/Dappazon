// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    // string public name;
    address public owner;

    constructor() {
        // name = "Dappazon";
        owner = msg.sender;
    }

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;

    event List(string name, uint256 cost, uint256 quantity);
    event Buy(address buyer,uint256 orderId,uint256 itemId);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // list product

    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );
        // save Item Struct to blockchain
        items[_id] = item;

        // emit an event
        emit List(_name, _cost, _stock);
    }

    // buy products

    function buy(uint256 _id) public payable {
        // Fetch item
        Item memory item = items[_id];
        // require enough eth to buy item
        require(msg.value >= item.cost);

        //require item is in stock
        require(item.stock >0);

        // Receiver Cpypto
        // Create an order
        Order memory order = Order(block.timestamp, item);

        // add order for user
        orderCount[msg.sender]++; // OrderId
        orders[msg.sender][orderCount[msg.sender]] = order;
        // Substrack stock
        items[_id].stock = item.stock -1;
        // Emit event

        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    // withdraw funds

    function withdraw() public onlyOwner{
        (bool success,) = owner.call{value:address(this).balance}("");
        require(success); 
    }

}
