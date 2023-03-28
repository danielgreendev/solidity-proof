pragma solidity ^0.8.0;
import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/hardhat/console.sol";

contract MissInternetToken is ERC20, ERC20Burnable, Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    address private devAddress = 0x14C60B42328236E8125eB1cf8459E5CaFCB161f6;
    uint256 private constant INITIAL_SUPPLY = 888888888888 * (10 ** 18);
    uint256 private constant MINIMUM_SUPPLY = 888888888 * (10 ** 18);
    uint256 public taxPeriod;
    uint256 public lastTaxTimestamp;
    mapping(address => uint256) private lastDividendPoints;
    uint256 private totalDividendPoints;
    event TaxDistributed(uint256 amount);

    constructor() ERC20("Miss Internet Token", "MISS") {
        devAddress = msg.sender; // for test
        _mint(msg.sender, INITIAL_SUPPLY);
        taxPeriod = 30 days;
        lastTaxTimestamp = block.timestamp;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "MISS: transfer from the zero address");
        require(recipient != address(0), "MISS: transfer to the zero address");
        require(amount > 0, "MISS: invalid amount");
        require(taxPeriod > 0, "MISS: invalid tax period");
        require(lastTaxTimestamp > 0, "MISS: invalid lastTaxTimestamp");
        uint256 senderBalance = balanceOf(sender);
        require(
            sender == devAddress ||
                senderBalance <= totalSupply().mul(1).div(100),
            "MISS: Exceeds 1% of total supply"
        );
        require(
            amount <= totalSupply().mul(5).div(1000) || sender == devAddress,
            "MISS: Exceeds 0.5% of total supply"
        );
        if (sender != owner() && recipient != owner()) {
            if (block.timestamp >= lastTaxTimestamp.add(taxPeriod)) {
                distributeTax();
            }
            if (sender != address(this)) {
                uint256 taxAmount = amount.mul(2).div(100);
                amount = amount.sub(taxAmount);
                uint256 liquidityAmount = taxAmount.mul(4).div(10);
                uint256 rewardAmount = taxAmount.mul(4).div(10);
                uint256 burnAmount = taxAmount.mul(2).div(10);
                super._transfer(sender, address(this), liquidityAmount);
                totalDividendPoints = totalDividendPoints.add(rewardAmount);
                lastDividendPoints[sender] = totalDividendPoints;
                lastDividendPoints[recipient] = totalDividendPoints;
                if (totalSupply() > MINIMUM_SUPPLY) {
                    _burn(address(this), burnAmount);
                }
            }
        }
        super._transfer(sender, recipient, amount);
    }

    function distributeTax() public nonReentrant {
        uint256 balance = balanceOf(address(this));
        require(balance > 0, "MISS: invalid balance");
        uint256 rewardAmount = balance.mul(4).div(10);
        require(rewardAmount > 0, "MISS: invalid rewardAmount");
        uint256 burnAmount = balance.mul(2).div(10);
        require(burnAmount > 0, "MISS: invalid burnAmount");
        totalDividendPoints = totalDividendPoints.add(rewardAmount);
        if (totalSupply() > MINIMUM_SUPPLY.add(burnAmount)) {
            _burn(address(this), burnAmount);
        } else if (totalSupply() > MINIMUM_SUPPLY) {
            uint256 actualBurnAmount = totalSupply().sub(MINIMUM_SUPPLY);
            _burn(address(this), actualBurnAmount);
        }
        lastTaxTimestamp = block.timestamp;
        emit TaxDistributed(balance);
    }

    function claimRewards() external nonReentrant {
        uint256 owing = rewardsOwing(msg.sender);
        require(owing > 0, "MISS: invalid rewardsOwing");
        lastDividendPoints[msg.sender] = totalDividendPoints;
        if (owing > 0) {            
            _transfer(address(this), msg.sender, owing);            
        }
    }

    function rewardsOwing(address account) public view returns (uint256) {
        require(account != address(0), "MISS: invalid account address");
        uint256 newDividendPoints = totalDividendPoints.sub(
            lastDividendPoints[account]
        );
        return balanceOf(account).mul(newDividendPoints).div(10 ** 18);
    }

    function unclaimedRewards(address account) external view returns (uint256) {
        require(account != address(0), "MISS: invalid account address");
        uint256 owing = rewardsOwing(account);
        require(owing > 0, "MISS: invalid rewardsOwing");
        return rewardsOwing(account);
    }
}