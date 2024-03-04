import './App.css';
import Home from './Components/Home';
import Community from './Components/Community';
import Docs from './Components/Docs';
import BorrowLend from './Components/BorrowLend';
import { BrowserRouter, Routes, Route } from "react-router-dom";


function App() {
  return (
    <>
     <BrowserRouter>
          <Routes>
            <Route path="/">
              <Route index element={<Home />} />
              <Route path="community" element={<Community />} />
              <Route path="docs" element={<Docs />} />
              <Route path="borrowLend" element={<BorrowLend />} />
            </Route>
          </Routes>
        </BrowserRouter>
    </>
  );
}

export default App;
