# ERC-20 Token Creation & Deployment Plan
## Free-Resources-Only Stack for Ethereum Sepolia Testnet

---

### 🎯 Objective
Create, test, and deploy a fungible ERC-20 token on Ethereum using **only free tools and testnets**. No mainnet costs.

---

### 🛠 Recommended Stack (100% Free)

| Category | Tool | Free Tier Details |
|----------|------|-------------------|
| **Framework** | **Foundry** (forge/cast/anvil) | Open source, no limits |
| **Language** | Solidity ^0.8.20 | Latest stable |
| **Libraries** | **OpenZeppelin Contracts v5** | MIT licensed, audited |
| **IDE** | VS Code + Solidity Extension | Free |
| **Testnet** | **Sepolia** | Current Ethereum testnet |
| **RPC Provider** | **Alchemy Free Tier** | 300M compute units/month |
| **Wallet** | **MetaMask** / Rabby | Free browser extension |
| **Faucet** | Alchemy / Google Cloud Sepolia Faucet | Free testnet ETH |
| **Explorer** | **Sepolia Etherscan** | Free verification & inspection |
| **CI/CD** | GitHub Actions | Free for public repos |

---

### 📋 Phase-by-Phase Execution Plan

#### Phase 1: Environment Setup (~15 min)
```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Create project
forge init erc20-token --force
cd erc20-token

# Install OpenZeppelin v5
forge install OpenZeppelin/openzeppelin-contracts@v5.0.0 --no-commit
```

#### Phase 2: Contract Development (~30-60 min)
**`src/MyToken.sol`** - Minimal ERC20 with optional features:
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MyToken is ERC20, ERC20Burnable, Ownable, ReentrancyGuard {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        _mint(msg.sender, initialSupply_);
    }

    function mint(address to, uint256 amount) external onlyOwner nonReentrant {
        _mint(to, amount);
    }
}
```

**Configuration** (`foundry.toml`):
```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.20"
optimizer = true
optimizer_runs = 200
via_ir = true

[rpc_endpoints]
sepolia = "${SEPOLIA_RPC_URL}"
```

#### Phase 3: Testing (~15 min)

**`test/MyToken.t.sol`**:
```solidity
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken token;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        token = new MyToken("Test Token", "TEST", 1_000_000 * 1e18);
    }

    function testInitialSupply() public {
        assertEq(token.totalSupply(), 1_000_000 * 1e18);
        assertEq(token.balanceOf(address(this)), 1_000_000 * 1e18);
    }

    function testTransfer() public {
        token.transfer(alice, 100 * 1e18);
        assertEq(token.balanceOf(alice), 100 * 1e18);
    }

    function testBurn() public {
        token.burn(50 * 1e18);
        assertEq(token.totalSupply(), 950_000 * 1e18);
    }

    function testMintOnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert(); // Not owner
        token.mint(bob, 100 * 1e18);
    }
}
```

Run: `forge test -vvv`

#### Phase 4: Local Testing with Anvil (~5 min)
```bash
# Terminal 1: Start local node
anvil

# Terminal 2: Deploy to local
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# Test interactively
cast call <CONTRACT> "name()(string)" --rpc-url http://localhost:8545
```

#### Phase 5: Sepolia Deployment (~10 min)

1. **Get Sepolia ETH**: Visit [Alchemy Sepolia Faucet](https://sepoliafaucet.com/) or [Google Cloud Faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

2. **Create `.env`**:
```env
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY
PRIVATE_KEY=your_wallet_private_key_without_0x
ETHERSCAN_API_KEY=your_etherscan_api_key  # optional, for verification
```

3. **Deploy script** (`script/Deploy.s.sol`):
```solidity
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/MyToken.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        
        MyToken token = new MyToken(
            "My Custom Token",
            "MCT",
            1_000_000 * 1e18  // 1M tokens
        );
        
        vm.stopBroadcast();
        
        console2.log("Deployed at:", address(token));
    }
}
```

4. **Execute**:
```bash
source .env
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
```

#### Phase 6: Verification & Interaction (~5 min)

```bash
# Verify on Etherscan (if not auto-verified)
forge verify-contract <CONTRACT_ADDRESS> src/MyToken.sol:MyToken --chain sepolia --etherscan-api-key $ETHERSCAN_API_KEY

# Add to MetaMask: Import token using contract address
# Test transfer via cast or MetaMask UI
cast send <CONTRACT> "transfer(address,uint256)" 0xRecipientAddress 1000000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY
```

---

### 🔐 Security Checklist
- [ ] Use OpenZeppelin's audited contracts (don't write ERC20 from scratch)
- [ ] Enable optimizer (`via_ir = true` in foundry.toml)
- [ ] Test with fuzzing: `forge test --fuzz-runs 10000`
- [ ] Check for reentrancy (use `ReentrancyGuard` if minting/burning)
- [ ] Verify on Etherscan for transparency
- [ ] Never commit private keys to git

---

### 💰 Cost Breakdown (All $0)
| Item | Cost |
|------|------|
| Foundry toolchain | Free (open source) |
| OpenZeppelin contracts | Free (MIT licensed) |
| Alchemy RPC (free tier) | Free (300M CU/mo) |
| Sepolia testnet ETH | Free (faucets) |
| Etherscan verification | Free |
| GitHub Actions CI | Free (public repo) |
| MetaMask wallet | Free |

---

### 📁 Final Project Structure
```
erc20-token/
├── .github/workflows/ci.yml      # Free CI (auto-test on push)
├── .env.example                  # Template (no secrets)
├── .gitignore                    # Exclude .env, out/, cache/
├── foundry.toml                  # Config
├── lib/                          # Git submodules (OpenZeppelin, forge-std)
├── script/
│   └── Deploy.s.sol              # Deployment script
├── src/
│   └── MyToken.sol               # Main contract
├── test/
│   └── MyToken.t.sol             # Unit + fuzz tests
└── README.md                     # Documentation
```

---

### ❓ Clarifying Questions (Answer Before Proceeding)

#### 1. Token Features Required
- [ ] **Basic ERC20 only** (transfer, balanceOf, allowance, approve)
- [ ] **Mintable by owner** (add supply later) ← *included above*
- [ ] **Burnable** (holders can destroy tokens) ← *included above*
- [ ] **Pausable** (emergency stop all transfers)
- [ ] **Permit / EIP-2612** (gasless approvals via signatures)
- [ ] **Votes / ERC20Votes** (governance voting power)
- [ ] **Flash Mint** (EIP-3156, uncollateralized loans)
- [ ] **Custom: _______________**

#### 2. Deployment Targets
- [ ] **Sepolia only** (recommended for testing)
- [ ] **Also Holesky** (alternative testnet)
- [ ] **Eventually Mainnet** (requires real ETH ~$50-200 gas)

#### 3. CI/CD & Automation
- [ ] **GitHub Actions** for automated testing on every push
- [ ] **Auto-deploy on tag** (e.g., `v1.0.0` → deploy to Sepolia)
- [ ] **No CI needed** (manual only)

#### 4. Team Workflow
- [ ] **Solo developer**
- [ ] **Multi-dev** (need branch protection, PR reviews, CODEOWNERS)

#### 5. Token Parameters (Decide Now)
| Parameter | Your Choice |
|-----------|-------------|
| **Name** | `My Custom Token` |
| **Symbol** | `MCT` |
| **Decimals** | `18` (standard) |
| **Initial Supply** | `1,000,000` tokens |
| **Recipient of Initial Supply** | Deployer (msg.sender) |

#### 6. Additional Tooling Preferences
- [ ] **Hardhat instead of Foundry** (JS/TS ecosystem, more plugins)
- [ ] **Remix IDE only** (no local install, browser-based)
- [ ] **Bun instead of Node** (faster, built-in test runner)

---

### 📝 Next Steps After Your Answers
1. I'll finalize the plan with your selections
2. Create feature-specific contract variants
3. Add CI/CD workflow if wanted
4. Document any custom requirements
5. **Then you can start Phase 1 installation**

---

*Answer the questions above and I'll refine the plan with your exact requirements.*