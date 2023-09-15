import "./Menu.css";

import React from "react";
import Button, { ButtonState } from "./Button";
import CustomText, { InlineType } from "./CustomText";

/**
 * Representation of menu object as sent by the client
 * Represents only a single menu.
 */
export interface MenuState {
  id: any;
  align: "right" | "left";
  title: string;
  subtitle?: InlineType[];
  buttons: ButtonState[];
  desc?: InlineType[];
}
// rexport for availability
export { ButtonState };

export interface Props {
  state: MenuState;
}
const Menu: React.FC<Props> = ({ state }) => (
  <div className="menu">
    {/* render title and sub-title (if exists) */}
    <div className="title-card">
      <h1>{state.title}</h1>
    </div>
    {state.subtitle && (
      <div className="subtitle-card">
        <h2>
          <CustomText>{state.subtitle}</CustomText>
        </h2>
      </div>
    )}

    {/* render each button */}
    <div className="button-group">
      {state.buttons.map((btn) => (
        <Button key={btn.id} state={btn} />
      ))}
    </div>

    {/* render description (if exists) */}
    {state.desc && (
      <div className="description">
        <CustomText>{state.desc}</CustomText>
      </div>
    )}
  </div>
);
export default Menu;
