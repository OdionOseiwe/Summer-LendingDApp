import { useReadContract, useAccount } from "wagmi";
import ABI from "../ABI/LendingDApp.json";
import ABIUSDC from "../ABI/MockUSDC.json"
import React, { useRef, useState } from "react";
import { LendingDapp, MockUSDC } from "../address";
import { parseEther, formatEther } from "viem";

function UsersDetails() {
  const account = useAccount();

  const { data: SuppliedData, isLoading } = useReadContract({
    address: LendingDapp,
    abi: ABI,
    functionName: "userDeposit",
    args: [account.address, "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd"],
  });

  const { data: lendData } = useReadContract({
    address: LendingDapp,
    abi: ABI,
    functionName: "userDeposit",
    args: [account.address, MockUSDC],
  });

  const { data: BorrowDataInUSDC } = useReadContract({
    address: LendingDapp,
    abi: ABI,
    functionName: "userBorrow",
    args: [account.address, "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd"],
  });

  const { data: lendRewardDebt } = useReadContract({
    address: LendingDapp,
    abi: ABI,
    functionName: "userDeposit",
    args: [account.address, MockUSDC],
  });

  const { data: rewardsContainer } = useReadContract({
    address: LendingDapp,
    abi: ABI,
    functionName: "rewards",
  });

  const { data: rewardsInUSDC } = useReadContract({
    address: LendingDapp,
    abi: ABI,
    functionName: "rewards",
  });

  const { data: allSummerUSDC } = useReadContract({
    address: MockUSDC,
    abi: ABIUSDC,
    functionName: "balanceOf",
    args:[LendingDapp]
  });

  let TotalAmountlended;
  let interest;

  if (!isLoading) {
    interest =
      (Number(lendData[0]) * Number(rewardsContainer[1])) / 1e18 -
      Number(lendRewardDebt[1]);
    interest = formatEther(interest);
    console.log(interest);
    console.log(Number.parseFloat(interest).toFixed(1));

    TotalAmountlended = formatEther(allSummerUSDC- rewardsInUSDC[0]);
    TotalAmountlended = Number.parseFloat(TotalAmountlended).toFixed(1);
  }


  return (
    <>
    <div className="SummerUSDBalance">{!isLoading ?TotalAmountlended: "0.0"} available to borrow</div>
      <div className="Users__DespositsDetails">
        <div className="lend">
          <div className="Lended--amount">
            Lended:
            {!isLoading ? (
              <span className="lended--span"> {formatEther(lendData[0])} </span>
            ) : (
              "0.0"
            )}
            USDC
          </div>
          <div className="Lended--interest">
            Yours interest:
            <span className="lended--interest">{!isLoading? Number.parseFloat(interest).toFixed(1): "0.0"}</span> USDC
          </div>
        </div>
        <div className="borrow">
          <div className="Supplied--amount">
            Supplied:
            <span className="Supplied--RealAmount">
              {!isLoading ? (
                <span className="lended--span">
                  {" "}
                  {formatEther(SuppliedData[0])}{" "}
                </span>
              ) : (
                "0.0"
              )}
            </span>{" "}
            BNB
          </div>
          <div className="borrowed--amount">
            Borrowed:
            <span className="borrowed--RealAmount">
              {!isLoading ? (
                <span className="lended--span">
                  {" "}
                  {formatEther(Number(BorrowDataInUSDC))}{" "}
                </span>
              ) : (
                "0.0"
              )}
            </span>
            USDC
          </div>
        </div>
      </div>
    </>
  );
}

export default UsersDetails;
