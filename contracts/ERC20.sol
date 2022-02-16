// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.11;

interface tokenRecipient{
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract Token{
    // Public Variables for the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // Creates an array with all balances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // geneartes a public event on blockchain which will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // genrates a public event on blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // They the clients about amount burnt
    event Burn(address indexed from, uint256 value);

    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    function _transfer(address _from, address _to, uint _value) internal{
        // Prevent transfer to 0x0 address. use burn() instead
        require(_to != address(0x0));
        // Check if sender has enough balance 
        require(balanceOf[_from] >= _value);
        // Check overflow
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Assertion in future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from sender
        balanceOf[_from] -= _value;
        // Add same to recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to find bugs 
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances); 
    }

        function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}

