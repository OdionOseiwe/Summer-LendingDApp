import { useState } from "react";
import React, { useRef } from "react";
import { LendingDapp } from "../address";
import ABI from "../ABI/LendingDApp.json";
import { useWriteContract} from "wagmi";
import { parseEther } from "viem";

const ModalLend = ({ setOpenL }) => {
  const [input, setInput] = useState("0.0");
  const { writeContract } = useWriteContract();
  const ref = useRef(null);

  
  const deposit = () =>{
    writeContract({
      address: LendingDapp,
      abi: ABI,
      functionName: "deposit",
      args: [
        "0x97b13B0fc0056139460da0Dd1F485FFC9d663A40",
        parseEther(input),
      ],
    })
    ref.current.value = "";
  }

  const withdraw = () => {
    writeContract({
      address: LendingDapp,
      abi: ABI,
      functionName: "withdraw",
      args: [
        "0x97b13B0fc0056139460da0Dd1F485FFC9d663A40", // MockUSDC
        parseEther(input),
      ],
      
    })
    ref.current.value = "";
  }

  // const { isLoading, data } = useReadContract({
  //   address: '0x6Cb9647c32f9B85b014bc16d5CE70C99D4200e81',
  //   abi:ABI,
  //   functionName: 'name',
  // });

  // console.log(data, isLoading);

  return (
    <>
      <div className="close" onClick={() => setOpenL(false)}></div>
      <div className="modal">
        <div className="Modal__action">
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
          <button
            className="modal__supply"
            onClick={deposit}
          >
            Lend
          </button>
          <button className="modal__withdraw" 
            onClick={withdraw}
          >withdraw</button>
        </div>
      </div>
    </>
  );
};

export default ModalLend;
