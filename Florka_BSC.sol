// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract FlorkaToken is ERC20, Pausable, Ownable, ReentrancyGuard {
    mapping(address => bool) private _blacklist;
    uint256 private constant MAX_SUPPLY = 100_000_000 * 10**18; // 100,000,000 tokens con 18 decimales

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);

    constructor() ERC20("Florka", "FLK") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);
    }

    modifier notBlacklisted(address account) {
        require(!_blacklist[account], "FlorkaToken: account is blacklisted");
        _;
    }

    function blacklist(address account) external onlyOwner {
        require(!_blacklist[account], "FlorkaToken: account is already blacklisted");
        _blacklist[account] = true;
        emit Blacklisted(account);
    }

    function unblacklist(address account) external onlyOwner {
        require(_blacklist[account], "FlorkaToken: account is not blacklisted");
        _blacklist[account] = false;
        emit UnBlacklisted(account);
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _blacklist[account];
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "FlorkaToken: mint would exceed max supply");
        _mint(to, amount);
    }

    function _update(address from, address to, uint256 amount) internal override whenNotPaused {
        require(!_blacklist[from] && !_blacklist[to], "FlorkaToken: blacklisted address");
        super._update(from, to, amount);
    }

    function transfer(address to, uint256 amount) public override nonReentrant returns (bool) {
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override nonReentrant returns (bool) {
        return super.transferFrom(from, to, amount);
    }
}
