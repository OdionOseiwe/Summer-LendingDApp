const ModalSupply=({setOpenS}) =>{
    return ( 
        <>
            <div className="close" onClick={()=>setOpenS(false)}></div>
            <div className="modal">
                <div className="Modal__action">
                    <div className="Modal__token">BNB</div>
                    <input className="Modal__input" type="text" />
                </div>
                <div className="Modal__Lend">
                    <button className="modal__supply">Supply</button>
                    <button className="modal__withdraw">withdraw</button>
                </div>
                
            </div>

        </> 
    );
}

export default ModalSupply;