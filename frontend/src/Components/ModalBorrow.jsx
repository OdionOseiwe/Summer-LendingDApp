import { useState } from "react";
import React, { useRef } from "react";
import { LendingDapp } from "../address";
import ABI from "../ABI/LendingDApp.json";
import { useWriteContract } from "wagmi";
import { parseEther , parseUnits} from "viem";

const ModalBorrow = ({ setOpenB }) => {
  const [input, setInput] = useState("0.0");
  const { writeContract } = useWriteContract();
  const ref = useRef(null);

  const borrow = () => {
    writeContract({
      address: LendingDapp,
      abi: ABI,
      functionName: "borrow",
      args: [parseEther(input), "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd"],
    });
    ref.current.value = "";
  };

  const repay = () => {
    writeContract({
      address: LendingDapp,
      abi: ABI,
      functionName: "repay",
      args: [parseEther(input), "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd"],
    });
    ref.current.value = "";
  };
  return (
    <>
      <div className="close" onClick={() => setOpenB(false)}></div>
      <div className="modal">
        <div className="Modal__action">
          <div className="Modal__token">You only borrow USDC</div>
          <div className="Modal__token">Input the amount of USDC you want to borrow or repay. You are paying 4% of borrow, with borrow</div>
          <input
            className="Modal__input"
            placeholder="0.0"
            type="text"
            onChange={(e) => setInput(e.target.value)}
            ref={ref}
          />
        </div>
        <div className="Modal__Lend">
          <button className="modal__supply" onClick={borrow}>
            Borrow
          </button>
          <button className="modal__withdraw" onClick={repay}>
            repay
          </button>
        </div>
      </div>
    </>
  );
};

export default ModalBorrow;
