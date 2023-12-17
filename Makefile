-include .env

deploy-sepolia:
		forge script script/DeployFundMe.s.sol --rpc-url $(RPC_URL) --broadcast --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-anvil:
		forge script script/DeployFundMe.s.sol --rpc-url $(RPC_URL) --broadcast --private-key $(PRIVATE_KEY) -vvvv

.PHONY: deploy-anvil