import { useState } from "react";
import React, { useRef } from "react";
import { LendingDapp } from "../address";
import ABI from "../ABI/LendingDApp.json";
import { useWriteContract } from "wagmi";
import { parseEther } from "viem";

const ModalSupply=({setOpenS}) =>{
    const [input, setInput] = useState("0.0");
    const { writeContract } = useWriteContract();
    const ref = useRef(null);
  
    
    const deposit = () =>{
      writeContract({
        address: LendingDapp,
        abi: ABI,
        functionName: "deposit",
        args: [
          "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd",
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
          "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd", // BNB
          parseEther(input),
        ],

      })
      ref.current.value = "";
    }
    return ( 
        <>
            <div className="close" onClick={()=>setOpenS(false)}></div>
            <div className="modal">
                <div className="Modal__action">
                    <div className="Modal__token"> Supply BNB as Collateral</div>
                    <div className="Modal__token">input the amount of BNB you want to supply or withdraw</div>
                    <input className="Modal__input" 
                        type="text" 
                        placeholder="0.0"
                        onChange={(e) => setInput(e.target.value)}
                        ref={ref}
                    />
                </div>
                <div className="Modal__Lend">
                    <button className="modal__supply" 
                        onClick={deposit}
                    >Supply</button>
                    <button className="modal__withdraw"
                        onClick={withdraw}
                    >withdraw</button>
                </div>
                
            </div>

        </> 
    );
}

export default ModalSupply;