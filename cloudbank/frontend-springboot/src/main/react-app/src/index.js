import { createRoot } from 'react-dom/client';
import './index.css';
import App from './components/App';
import {BrowserRouter, Route, Routes} from "react-router-dom";


const container = document.getElementById('root');
const root = createRoot(container);
root.render(
    <BrowserRouter>
      <Routes>
          <Route path="/*" element={<App/>} />
      </Routes>
    </BrowserRouter>
);
