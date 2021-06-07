import logo from './logo.svg';
import './App.css';
import React from 'react';
import ReactDOM from 'react-dom';
import { ChromePicker, SketchPicker } from 'react-color'
import { ColorPicker } from './components/color_picker'

class SolidForm extends React.Component {

  state = {
    color:{r: 0, b:0, g:0},
  };

  getData() {
    return ({
      type: "pattern",
      data: {
        pattern: "solid",
        color: [this.state.color.b, this.state.color.g, this.state.color.r, 0]
      }
    })
  }

  handleColor = (color) => {
    console.log(this.state);
    this.setState({
      color: color.rgb
    })
  }

  handleSubmit = (event) => {
    let response = fetch('/api/pattern', {
      method: 'POST',
      body: JSON.stringify(this.getData())
    }).then(function (response) {
      console.log(response)
      return response.json();
    });


    if (response.status == "error") {
      alert(`Failed to set lights: ${response.message}`)
    }

    event.preventDefault();
  }

  render() {
    return (
      <div>
        <ColorPicker color={this.state.color}>
          <ChromePicker color={this.state.color} onChange={this.handleColor} />
        </ColorPicker>
        <button onClick={this.handleSubmit}>Submit</button>
        </div>
    );
  }
}

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <SolidForm />
      </header>
    </div>
  );
}

export default App;
