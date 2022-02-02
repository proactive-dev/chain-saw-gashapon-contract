# Gashapon Contract Project

## How to use Hardhat and smart contracts
### Install packages
```
yarn install
```

### Configure environment variables, and setup hardhat project
```
vi .env
vi hardhat.config.js
```

### Edit main contract
```
vi ./contracts/AlchemicaToken.sol
```

### Compile contract
```
npx hardhat compile
```

### Run deploy script to deploy contract
```
vi ./scripts/deploy.js
npx hardhat run scripts/deploy.js --network local
```
