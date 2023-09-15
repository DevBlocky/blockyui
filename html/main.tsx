import React from "react";
import ReactDOM from "react-dom";
import { library } from "@fortawesome/fontawesome-svg-core";
import { fas } from "@fortawesome/free-solid-svg-icons";
import { far } from "@fortawesome/free-regular-svg-icons";
import App from "./App";

// add fontawesome libraries
library.add(fas, far);

const root = document.createElement("div");
root.id = "root";
document.body.appendChild(root);

ReactDOM.render(<App />, root);
