// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GashaponNFT is ERC721, ERC721Holder, Ownable {
  event Paused(uint _drop);
  event Unpaused(uint _drop);

  uint constant DROP_COUNT = 5;
  uint constant AMOUNT_PER_DROP = 600;

  string private _baseTokenURI;
  mapping (uint => bool) private _paused;
  mapping (uint => uint) private _dropsSale;

  uint public salePrice = 0.1 ether;
  uint public maxAmountPerTrx = 5;

  constructor() ERC721("Cool3dToys","C3DT") {
    _baseTokenURI = "https://ipfs.io/ipfs/"; // TODO: Replace

    uint _totalSupply = AMOUNT_PER_DROP * DROP_COUNT;
    for (uint256 i; i < _totalSupply; i++) {
      _mint(address(this), i + 1);
    }

    _pauseAll();
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
    return string(abi.encodePacked(_baseTokenURI, _tokenId));
  }

  function sale(uint _drop) external payable isHuman {
    require(!paused(_drop), "Drop paused");

    // verify that the user sent enough eth to pay for the sale
    uint remainder = msg.value % salePrice;
    require(remainder == 0, "Send a divisible amount of ether");

    // calculate and validate the amount of tokens we are minting based on the amount of eth sent
    uint amount = msg.value / salePrice;
    require(amount > 0, "Amount to mint is 0");
    require(amount <= maxAmountPerTrx, "Surpass max mint cap per transaction");

    // sale
    uint _estimatedDropSale = _dropsSale[_drop] + amount;
    require((_estimatedDropSale) <= AMOUNT_PER_DROP, "Drop sold out");

    _sale(_drop, amount, msg.sender);
    _dropsSale[_drop] = _estimatedDropSale;
  }

  function _sale(uint _drop, uint _amount, address _to) internal {
    for (uint i = 0; i < _amount; i++) {
      // get random token id and check already sold
      uint _tokenId;
      do {
        _tokenId = (_drop - 1) * AMOUNT_PER_DROP + rnd();
      } while (isSold(_tokenId));
      // transfer
      _transfer(address(this), _to, _tokenId);
    }
  }

  function setSalePrice(uint _salePrice) public onlyOwner {
    salePrice = _salePrice;
  }

  function setMaxAmountPerTrx(uint _maxAmountPerTrx) public onlyOwner {
    maxAmountPerTrx = _maxAmountPerTrx;
  }

  function soldOut(uint _drop) public view returns (bool) {
    return _dropsSale[_drop] >= AMOUNT_PER_DROP;
  }

  function isSold(uint256 _tokenId) internal view returns (bool) {
    return ownerOf(_tokenId) != address(this);
  }

  function rnd() internal view returns(uint256) {
    uint256 seed = uint256(keccak256(abi.encodePacked(
        block.timestamp + block.difficulty +
        ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)) +
        block.gaslimit +
        ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)) +
        block.number
      )));

    return (seed - ((seed / AMOUNT_PER_DROP) * AMOUNT_PER_DROP));
  }

  // Pausable for drops
  function pause(uint[] calldata _drops) public onlyOwner {
    for (uint256 i; i < _drops.length; i++) {
      if(_drops[i] <= DROP_COUNT) {
        _pause(_drops[i]);
      }
    }
  }

  function unpause(uint[] calldata _drops) public onlyOwner {
    for (uint256 i; i < _drops.length; i++) {
      if(_drops[i] <= DROP_COUNT) {
        _unpause(_drops[i]);
      }
    }
  }

  function pauseAll() public onlyOwner {
    _pauseAll();
  }

  function unpauseAll() public onlyOwner {
    _unpauseAll();
  }

  function _pauseAll() internal {
    for (uint256 i = 1; i <= DROP_COUNT; i++) {
      _pause(i);
    }
  }

  function _unpauseAll() internal {
    for (uint256 i = 1; i <= DROP_COUNT; i++) {
      _unpause(i);
    }
  }

  function _pause(uint _drop) internal {
    if(!paused(_drop)) {
      _paused[_drop] = true;
      emit Paused(_drop);
    }
  }

  function _unpause(uint _drop) internal {
    if(paused(_drop)) {
      _paused[_drop] = false;
      emit Unpaused(_drop);
    }
  }

  function paused(uint _drop) public view returns (bool) {
    return _paused[_drop];
  }

  modifier whenNotPaused(uint _drop) {
    require(!paused(_drop), "Drop paused");
    _;
  }

  modifier whenPaused(uint _drop) {
    require(paused(_drop), "Drop not paused");
    _;
  }

  // This modifier is used to prevent contract to interact with this.
  modifier isHuman() {
    require(tx.origin == msg.sender, "EOA only");
    _;
  }
}
