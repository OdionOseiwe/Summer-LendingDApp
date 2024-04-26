import { useState } from "react";
import React, { useRef } from "react";
import { LendingDapp, MockUSDC } from "../address";
import ABI from "../ABI/LendingDApp.json";
import AbiMockUSDC from "../ABI/MockUSDC.json";
import { parseEther } from "viem";
import { useWeb3Contract } from "react-moralis";
import { useToasts } from "react-toast-notifications";

const ModalLend = ({ setOpenL }) => {
  const [input, setInput] = useState("0.0");
  const [open, setOpen] = useState(true);
  const ref = useRef(null);
  const { addToast } = useToasts();

  const { runContractFunction: approve } = useWeb3Contract({
    abi: AbiMockUSDC,
    contractAddress: MockUSDC,
    functionName: "approve",
    params: {
      spender: LendingDapp,
      value: parseEther(input),
    },
  });

  const { runContractFunction: deposit } = useWeb3Contract({
    abi: ABI,
    contractAddress: LendingDapp,
    functionName: "deposit",
    params: {
      token: "0x97b13B0fc0056139460da0Dd1F485FFC9d663A40",
      amount: parseEther(input),
    },
  });

  async function handleDepositClick() {
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

    await deposit({
      onError: (error) => {
        addToast(error.message, { appearance: "error", autoDismiss: true });
      },
      onSuccess: () => {
        addToast("Wow you just depsited",{
          appearance: "success",
          autoDismiss: true,
        });
      },
    });

    ref.current.value = "";
  }

  const { runContractFunction: withdraw } = useWeb3Contract({
    abi: ABI,
    contractAddress: LendingDapp,
    functionName: "withdraw",
    params: {
      token: "0x97b13B0fc0056139460da0Dd1F485FFC9d663A40", // MockUSDC
      amount: parseEther(input),
    },
  });

  async function handleWithdrawClick() {
    await withdraw({
      onError: (error) => {
        addToast(error.message, { appearance: "error" });
      },
      onSuccess: (tx) => {
        addToast("Wow you just withdraw", {
          appearance: "success",
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
            <div className="Modal__token"> You can only Lend USDC</div>
            <input
              className="Modal__input"
              placeholder="0.0"
              type="text"
              onChange={(e) => setInput(e.target.value)}
              ref={ref}
            />
          </div>
          <div className="Modal__Lend">
            <button className="modal__supply" onClick={handleDepositClick}>
              Lend
            </button>
            <button className="modal__withdraw" onClick={handleWithdrawClick}>
              withdraw
            </button>
          </div>
        </div>
      )}
    </>
  );
};

export default ModalLend;
