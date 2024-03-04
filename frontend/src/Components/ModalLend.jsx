// import { useState } from "react";
// import { LendingDapp } from '../address';
// import ABI from "../ABI/LendingDApp.json";
// import { useWriteContract } from 'wagmi'
// import { parseEther } from 'viem';
// const ModalLend=({setOpenL,setALendmount}) =>{
//     const [input, setInput] = useState('0.0');
//     const { writeContract } = useWriteContract()

//     const deposit = () =>{
//         writeContract({ 
//             ABI,
//             address: LendingDapp,
//             functionName: 'deposit',
//             args: [
//               '0x70f0a84CaBeB6798ea55BeD3552FDd54b2Ae8269',
//               parseEther(input),
//             ],
//          })
//     }

//     return ( 
//         <>
//             <div className="close" onClick={()=>setOpenL(false)}></div>
//             <div className="modal">
//                 <div className="Modal__action">
//                     <div className="Modal__token">BNB</div>
//                     <input className="Modal__input"  placeholder="0.0" type="text" onChange={(e) => setInput(e.target.value)} />
//                 </div>
//                 <div className="Modal__Lend">
//                     <button className="modal__supply" onClick={()=>deposit}>Lend</button>
//                     <button className="modal__withdraw">withdraw</button>
//                 </div>
                
//             </div>

//         </> 
//     );
// }

// export default ModalLend;