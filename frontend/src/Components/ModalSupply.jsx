import { useState } from "react";
import React, { useRef } from "react";
import { LendingDapp } from "../address";
import ABI from "../ABI/LendingDApp.json";
import AbiWBNB from "../ABI/WBNB.json"
import { parseEther } from "viem";
import { useWeb3Contract } from "react-moralis";
import { useToasts } from "react-toast-notifications";

const ModalSupply=({setOpenS}) =>{
    const [input, setInput] = useState("0.0");
    const [open, setOpen] = useState(true);
    const ref = useRef(null);
    const { addToast } = useToasts();


    const { runContractFunction: approve } = useWeb3Contract({
      abi: AbiWBNB,
      contractAddress: '0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd',
      functionName: "approve",
      params: {
        guy: LendingDapp,
        wad: parseEther(input),
      },
    });
  
    const { runContractFunction: deposit } = useWeb3Contract({
      abi: ABI,
      contractAddress: LendingDapp,
      functionName: "deposit",
      params: {
        token: "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd", //WBNB
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
          addToast("Wow you just supplied" , {
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
        token: "0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd", // WBNB
        amount: parseEther(input),
      },
    });
  
    async function handleWithdrawClick() {
      await withdraw({
        onError: (error) => {
          addToast(error.message, { appearance: "error" });
        },
        onSuccess: (tx) => {
          addToast("Wow you just withdrawed", {
            appearance: "success",
            autoDismiss: true,
          });
        },
      });
  
      ref.current.value = "";
    }
  
    return ( 
        <>
              {
                open && (
                  <div className="modal">

                  <div className="Modal__action">
                  <div className="close" onClick={() => setOpen(false)}>
                    X
                  </div>
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
                        onClick={handleDepositClick}
                    >Supply</button>
                    <button className="modal__withdraw"
                        onClick={handleWithdrawClick}
                    >withdraw</button>
                </div>
                
            </div>
                )
              }
        </> 
    );
}

export default ModalSupply;