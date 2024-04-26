import ABI from "../ABI/LendingDApp.json";
import ABIUSDC from "../ABI/MockUSDC.json";
import React, { useState, useEffect } from "react";
import { LendingDapp, MockUSDC } from "../address";
import { formatEther, hexToNumber } from "viem";
import { useWeb3Contract } from "react-moralis";
var console = require("console-browserify");

function UserDetail() {
  const [amountLend, setamountLend] = useState(0.0);
  const [amountBorrow, setamountBorrow] = useState(0.0);
  const [lendRewardDebt, setlendRewardDebt] = useState(0);
  const [allInterestInUSD, setallInterestInUSD] = useState(0);
  const [rewardPerToken, setrewardPerToken] = useState(0);
  const [balance, setBalance] = useState(0);
  const [supplied, setSuplied] = useState(0.0);

  let TotalAmountlended;

  const { runContractFunction: getUserDepositAmount } = useWeb3Contract({
    abi: ABI,
    contractAddress: LendingDapp,
    functionName: "getUserDepositAmount",
    params: {
      collateral: MockUSDC,
    },
  });

  const { runContractFunction: getUserSuppliedAmount } = useWeb3Contract({
    abi: ABI,
    contractAddress: LendingDapp,
    functionName: "getUserDepositAmount",
    params: {
      collateral: "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
    },
  });

  const { runContractFunction: getUserBorrowAmount } = useWeb3Contract({
    abi: ABI,
    contractAddress: LendingDapp,
    functionName: "getUserBorrowAmount",
    params: {
      collateral: "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
    },
  });
  const { runContractFunction: rewards } = useWeb3Contract({
    contractAddress: LendingDapp,
    abi: ABI,
    functionName: "rewards",
  });

  const { runContractFunction: balanceOf } = useWeb3Contract({
    contractAddress: MockUSDC,
    abi: ABIUSDC,
    functionName: "balanceOf",
    params: {
      account: LendingDapp,
    },
  });

  useEffect(() => {
    const fetchData = async () => {
      try {
        let borrowAmount = await getUserBorrowAmount();
        let lend = await getUserDepositAmount();
        let rewardss = await rewards();
        let balance = await balanceOf();
        let supply = await getUserSuppliedAmount();

        setamountBorrow(formatEther(hexToNumber(borrowAmount._hex)));
        setamountLend(formatEther(hexToNumber(lend.amount._hex)));
        setlendRewardDebt(formatEther(hexToNumber(lend.rewardDebt._hex)));
        setallInterestInUSD(
          formatEther(hexToNumber(rewardss.allInterestInUSD._hex))
        );
        setrewardPerToken(
          formatEther(hexToNumber(rewardss.rewardPerToken._hex))
        );
        setBalance(formatEther(hexToNumber(balance._hex)));
        setSuplied(formatEther(hexToNumber(supply.amount._hex)));
      } catch (error) {
        console.error("Error reading data from contract:", error);
      }
    };

    fetchData();
  }, );

  let interest;

  interest = (amountLend * rewardPerToken) - lendRewardDebt;
  TotalAmountlended = balance - allInterestInUSD;
  TotalAmountlended = Number.parseFloat(TotalAmountlended).toFixed(1);

  return (
    <>
      <div className="SummerUSDBalance">
        {TotalAmountlended} available to borrow
      </div>
      <div className="Users__DespositsDetails">
        <div className="lend">
          <div className="Lended--amount">
            Lended:
            <span className="lended--span"> {amountLend} </span>
            USDC
          </div>
          <div className="Lended--interest">
            Yours interest:
            <span className="lended--interest">
              {Number.parseFloat(interest).toFixed(1)}
            </span>
            USDC
          </div>
        </div>
        <div className="borrow">
          <div className="Supplied--amount">
            Supplied:
            <span className="Supplied--RealAmount">
              <span className="lended--span">{supplied}</span>
            </span>
            BNB
          </div>
          <div className="borrowed--amount">
            Borrowed:
            <span className="borrowed--RealAmount">
              <span className="lended--span">{amountBorrow}</span>
            </span>
            USDC
          </div>
        </div>
      </div>
    </>
  );
}

export default UserDetail;
