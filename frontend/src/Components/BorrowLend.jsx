import Nav from './nav';
import React, { useState } from 'react';
import ModalLend from './ModalLend';
import ModalBorrow from './ModalBorrow'
import ModalSupply from './ModalSupply'


function BorrowLend() {
    const [openL ,setOpenL] = React.useState(false);
    const [openB ,setOpenB] = React.useState(false);
    const [openS ,setOpenS] = React.useState(false);
    const [LendAmount, setALendmount] = useState('0.0');


    return (
        <>
            <div className="BorrowLend">
            <Nav/>
                <div className="BorrowLend__header">
                    <div className="BorrowLend__heading">Borrow / Lend</div>
                    <div className="BorrowLend__des">Supply assets to earn yield and borrow against collateral</div>
                </div>

                <div className="Assets">
                <div className="Assets__Lend">
                    <div className="Asset__lend_des">
                        <div className="Asset__tokens">assets</div>
                        <div className="Asset__APYs">APY%</div>
                        <div className="Asset__supplys"></div>
                    </div>
                    <div className="Asset__lends">
                        <div className="Asset__token">USDT</div>
                        <div className="Asset__APY">10%</div>
                        <button className="Asset__supply" onClick={()=>setOpenL(true)}>lend</button>
                        {openL && <ModalLend setOpenL={setOpenL} setALendmount = {setALendmount} />}
                    </div>
                </div>
                <div className="Assets__Supply">
                    <div className="Asset__lend_des2">
                        <div className="Asset__tokens">assets</div>
                        <div className="Asset__APYs">LTV</div>
                        <div className="Asset__supplys"></div>
                        <div className="Asset__borrows"></div>
                    </div>
                    <div className="Asset__lend_des2">
                        <div className="Asset__token">BNB</div>
                        <div className="Asset__APY">80%</div>
                        <button className="Asset__supply" onClick={()=>setOpenS(true)}>supply</button>
                        {openS && <ModalSupply setOpenS={setOpenS} />}

                        <button className="Asset__borrow" onClick={()=>setOpenB(true)}>borrow</button>
                        {openB && <ModalBorrow setOpenB={setOpenB} />}                    
                    </div>
                </div>
            </div>
            </div>
            
        </> 
    );
}

export default BorrowLend;