import "reset-css";
import "./App.css";

import React, { useEffect, useState } from "react";
import Menu, { MenuState } from "./Menu";

declare function GetParentResourceName(): string;

function useMessageListener<T = any>(
  listener: (this: Window, ev: MessageEvent<T>) => any
) {
  useEffect(() => {
    window.addEventListener("message", listener);
    return () => window.removeEventListener("message", listener);
  }, [listener]);
}

let exampleState: MenuState = {
  id: 0,
  align: "right",
  title: "Just Another Menu",
  subtitle: ["Hello World"],
  buttons: [
    {
      id: 1,
      left: ["Example Button 1"],
      right: [
        { type: "icon", prefix: "fas", name: "chevron-left" },
        " List ",
        { type: "icon", prefix: "fas", name: "chevron-right" },
      ],
    },
    {
      id: 2,
      left: [
        { type: "icon", prefix: "fas", name: "lock" },
        " ",
        "Disabled Button",
      ],
      disabled: true,
    },
    {
      id: 3,
      left: ["Example Checkbox"],
      right: [{ type: "icon", prefix: "fas", name: "check-square" }],
      selected: true,
    },
  ],
};

const App: React.FC = () => {
  const [state, setState] = useState<MenuState[]>([]);

  useMessageListener(({ data }) => {
    if (data.type === "render") setState(data.menus);
  });
  useEffect(() => {
    fetch(`https://${GetParentResourceName()}/ready`, { method: "POST" });
  }, []);

  return (
    <React.Fragment>
      <div className="menu-container left">
        {state
          .filter((x) => x.align === "left")
          .map((x) => (
            <Menu key={x.id} state={x} />
          ))}
      </div>
      <div className="menu-container right">
        {state
          .filter((x) => x.align === "right")
          .map((x) => (
            <Menu key={x.id} state={x} />
          ))}
      </div>
    </React.Fragment>
  );
};
export default App;
