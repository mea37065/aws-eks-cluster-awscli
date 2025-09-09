#!/usr/bin/env bash
set -euo pipefail

CYAN="\033[0;36m"; MAGENTA="\033[0;35m"; GREEN="\033[0;32m"; RED="\033[0;31m"; NC="\033[0m"

echo -e "${MAGENTA}=== Delete VPC CloudFormation Stack ===${NC}"

if [ -f .env ]; then set -a; source .env; set +a; fi

read -rp "$(echo -e "${CYAN}VPC stack name [${VPC_STACK_NAME:-eks-vpc}]:${NC}") " VPC_STACK_INPUT
VPC_STACK_NAME="${VPC_STACK_INPUT:-${VPC_STACK_NAME:-eks-vpc}}"

read -rp "$(echo -e "${CYAN}AWS region [${AWS_REGION:-eu-central-1}]:${NC}") " AWS_REGION_INPUT
AWS_REGION="${AWS_REGION_INPUT:-${AWS_REGION:-eu-central-1}}"

aws cloudformation delete-stack --stack-name "${VPC_STACK_NAME}" --region "${AWS_REGION}"
echo -e "${MAGENTA}Waiting for stack deletion...${NC}"
aws cloudformation wait stack-delete-complete --stack-name "${VPC_STACK_NAME}" --region "${AWS_REGION}"

echo -e "${GREEN}VPC stack ${VPC_STACK_NAME} deleted.${NC}"
