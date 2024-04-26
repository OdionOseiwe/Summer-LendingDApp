import { useState } from "react";
import React, { useRef } from "react";
import { LendingDapp,MockUSDC } from "../address";
import ABI from "../ABI/LendingDApp.json";
import { useToasts } from "react-toast-notifications";
import { parseEther } from "viem";
import {useWeb3Contract } from "react-moralis";
import AbiMockUSDC from "../ABI/MockUSDC.json";


const ModalBorrow = ({ setOpenB }) => {
  const [input, setInput] = useState("0.0");
  const { addToast } = useToasts();
  const ref = useRef(null);
  const [open, setOpen] = useState(true);

  const { runContractFunction: approve } = useWeb3Contract({
    abi: AbiMockUSDC,
    contractAddress: MockUSDC,
    functionName: "approve",
    params: {
      spender: LendingDapp,
      value: parseEther(input),
    },
  });

  const { runContractFunction: repay } = useWeb3Contract({
    abi: ABI,
    contractAddress: LendingDapp,
    functionName: "repay",
    params: {
      amount: parseEther(input),
      token: "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
    },
  });

  async function handleRepayClick() {
    await approve({
      onError: (error) => {
        addToast(error.message, { appearance: "error", autoDismiss: true });
      },
      onSuccess: (tx) => {
        addToast("approved successfully", {
          appearance: "success",
          autoDismiss: true,
        });
        doDeposit(tx);
      },
    });
  }

  async function doDeposit(tx) {
    await tx.wait(1);

    await repay({
      onError: (error) => {
        addToast(error.message, { appearance: "error", autoDismiss: true });
      },
      onSuccess: () => {
        addToast("Wow you just repayed",{
          appearance: "success",
          autoDismiss: true,
        });
      },
    });

    ref.current.value = "";
  }

  const { runContractFunction: borrow } = useWeb3Contract({
    abi: ABI,
    contractAddress: LendingDapp,
    functionName: "borrow",
    params: {
        amount: parseEther(input), 
        token: "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
    },
});

  async function handleBorowClick() {
    await borrow({
      onError: (error) => {
        addToast(error.message, { appearance: "error" });
      },
      onSuccess: (tx) => {
        addToast("Wow you just borrowed", {
          appearance: "success",
          autoDismiss: true,
        });
      },
    });

    ref.current.value = "";
  }

  return (
    <>
      {open && (
        <div className="modal">
          <div className="Modal__action">
            <div className="close" onClick={() => setOpen(false)}>
              X
            </div>
            <div className="Modal__token">You only borrow USDC</div>
            <div className="Modal__token">
              Input the amount of USDC you want to borrow or repay. You are
              paying 4% of borrow, with borrow
            </div>
            <input
              className="Modal__input"
              placeholder="0.0"
              type="text"
              onChange={(e) => setInput(e.target.value)}
              ref={ref}
            />
          </div>
          <div className="Modal__Lend">
            <button className="modal__supply" onClick={handleBorowClick}>
              Borrow
            </button>
            <button className="modal__withdraw" onClick={handleRepayClick}>
              repay
            </button>
          </div>
        </div>
      )}
    </>
  );
};

export default ModalBorrow;
