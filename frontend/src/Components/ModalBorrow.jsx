const ModalBorrow=({setOpenB}) =>{
    return ( 
        <>
            <div className="close" onClick={()=>setOpenB(false)}></div>
            <div className="modal">
                <div className="Modal__action">
                    <div className="Modal__token">BNB</div>
                    <input className="Modal__input" type="text" />
                </div>
                <div className="Modal__Lend">
                    <button className="modal__supply">Borrow</button>
                    <button className="modal__withdraw">repay</button>
                </div>
                
            </div>

        </> 
    );
}

export default ModalBorrow;