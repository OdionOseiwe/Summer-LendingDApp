import { Outlet, Link } from "react-router-dom";
import BorrowLend from "./BorrowLend";

function Body() {
    return ( 
        <>  
            <div className="Body">
                <div className="Body__Title">Make the most of your <span className="Body__Crypto">cryptocurrency</span></div>
                <div className="Body__description">Summer is making credit more accessible, transparent, and programmable by bringing debt infrastructure on-chain.</div>
                <Link to= "BorrowLend"  className="Body__LaunchApp">Go to app</Link >
            </div>
            <Outlet/>
        </>
        
     );
}

export default Body;