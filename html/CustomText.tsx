import "./CustomText.css";
import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  IconPrefix,
  IconName,
  SizeProp,
} from "@fortawesome/fontawesome-svg-core";

export type InlineType =
  | string
  | { type: "text"; text: string }
  | { type: "icon"; prefix: IconPrefix; name: IconName; size?: SizeProp | null }
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
        <div className="inline-icon" key={i}>
          <FontAwesomeIcon
            icon={[x.prefix, x.name]}
            size={x.size || undefined}
          />
        </div>
      );
    else if (x.type === "template")
      return (
        <span key={i} dangerouslySetInnerHTML={{ __html: x.template }}></span>
      );
  });

  return <div className="custom-text">{components}</div>;
};
export default CustomText;
