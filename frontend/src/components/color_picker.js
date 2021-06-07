'use strict'

import React from 'react'
import { ChromePicker } from 'react-color'

class ColorPicker extends React.Component {
    constructor (props) {
        super(props)
        this.state = {
            displayColorPicker: false,
        };
    }


  handleClick = () => {
    this.setState({ displayColorPicker: !this.state.displayColorPicker })
  };

  handleClose = () => {
    this.setState({ displayColorPicker: false })
  };

  render() {
    const popover = {
      position: 'absolute',
      zIndex: '2',
    }
    const cover = {
      position: 'fixed',
      top: '0px',
      right: '0px',
      bottom: '0px',
      left: '0px',
    }

    let box = {
        display: "inline",
        float: "left",
        height: "20px",
        width: "20px",
        marginBottom: "15px",
        border: "1px solid black",
        clear: "both",
        backgroundColor: "rgb(" + this.props.color.r + "," + this.props.color.g + "," + this.props.color.b + ")"
    }

    const button = {
        display: "inline"
    }

    return (
      <div>
        <div style={box} />
        <button onClick={ this.handleClick } style={button}>Pick Color</button>
        { this.state.displayColorPicker ? <div style={ popover }>
          <div style={ cover } onClick={ this.handleClose }/>
          {this.props.children}
        </div> : null }
      </div>
    )
  }
}

export { ColorPicker }