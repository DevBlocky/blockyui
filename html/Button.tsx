import "./Button.css";

import React from "react";
import CustomText, { InlineType } from "./CustomText";
import clsx from "clsx";

export interface ButtonState {
  id: any;
  left?: InlineType[];
  right?: InlineType[];
  selected?: boolean;
  disabled?: boolean;
}

export interface ButtonProps {
  state: ButtonState;
}
const Button: React.FC<ButtonProps> = ({ state }) => (
  <div
    className={clsx(
      "button",
      state.selected && "selected",
      state.disabled && "disabled"
    )}
  >
    <div>{state.left && <CustomText>{state.left}</CustomText>}</div>
    <div>{state.right && <CustomText>{state.right}</CustomText>}</div>
  </div>
);
export default Button;
