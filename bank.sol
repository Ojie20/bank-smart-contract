// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    // event Transfer(address indexed from, address indexed to, uint256 value);
    // event Approval(address indexed owner, address indexed spender, uint256 value);
  }

contract Bank {

  IERC20 public token1;

  constructor(address _token1){
    token1 = IERC20(_token1);
  }

  // Enum definition
  enum Status {
        Pending,
        Rejected,
        Successful
    }

  
  struct User{
      string name;
      address addr;
      uint256 balance;
    }

    mapping (address=> User) public link;
    // Mapping from address to uint

  // register a user by linking an address to a struct
  function registerUser(string memory _name) public {
        // Create a new User struct and add it to the mapping
        link[msg.sender] = User({
            name: _name,
            addr: msg.sender,
            balance: 0
        });
    }

    // Function to get user details
    function getUser() public view returns (string memory, address, uint) {
        User memory user = link[msg.sender];

        return (user.name, user.addr, user.balance);
    }
  // modifier to detect smart contracts
    modifier detect1() {
    require(msg.sender == tx.origin , "Caller is a smart contract");
    _;
    }

    modifier minDep(uint256 i) {
        require(i > 50, "Deposit amount is too little");
        _;
    }

    modifier maxWith(uint256 i) {
        require(i < 10000, "Withdrawal amount is too much");
        _;
    }

    function getBalance() public view returns (uint256) {
        // Mapping always returns a value.
        // If the value was never set, it will return the default value.
        return link[msg.sender].balance;
    }


    function withdraw(uint256 amount) 
      public
      detect1
      maxWith(amount) returns(Status)
    {
      Status status;
      status = Status.Pending;
      if (token1.transfer(msg.sender, amount)) {
        status =Status.Successful;
      } else {
        status = Status.Rejected;
        return status;
      }
      link[msg.sender].balance -= amount;
      return status;
    }

    function deposit(uint256 amount)
     public
     detect1
     minDep(amount) returns(Status)
     {
      Status status;
      status = Status.Pending;
      if (token1.transferFrom(msg.sender, address(this), amount)) {
        status =Status.Successful;
      } else {
        status = Status.Rejected;
        return status;
      }
      link[msg.sender].balance -= amount;
      return status;
    }
}
