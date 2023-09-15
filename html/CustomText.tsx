import "./CustomText.css";
import React from "react";

export type InlineType =
  | string
  | { type: "text"; text: string }
  | { type: "icon"; name: string; fill?: boolean }
  | { type: "template"; template: string };
const CustomText: (props: {
  children?: InlineType[];
}) => JSX.Element | null = ({ children }) => {
  if (!children) return null;

  let components = children.map((x, i) => {
    if (typeof x === "string" || x.type === "text")
      return <span key={i}>{typeof x === "string" ? x : x.text}</span>;
    else if (x.type === "icon")
      return (
        <span
          className="material-symbols-outlined"
          style={{
            fontSize: "1.2em",
            fontVariationSettings: x.fill ? "'FILL' 1" : "",
          }}
        >
          {x.name}
        </span>
      );
    else if (x.type === "template")
      return (
        <span key={i} dangerouslySetInnerHTML={{ __html: x.template }}></span>
      );
  });

  return <div className="custom-text">{components}</div>;
};
export default CustomText;
