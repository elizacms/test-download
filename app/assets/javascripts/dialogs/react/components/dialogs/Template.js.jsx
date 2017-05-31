var Template = React.createClass({
  getInitialState() {
    return {
      templateType: null,
      childrenDataArray: [{}]
    };
  },

  componentDidMount() {
    const tType = this.props.templateType; // Options or Cards

    this.setState({
      templateType: tType
    });

    if (!this.props.value[tType]) {  // Do not update state if it's not Options or Cards
      return false;
    }

    if (this.props.value[tType].length > 0){
      this.setState({
        childrenDataArray: this.props.value[tType]
      });
    }
  },

  componentWillReceiveProps(nextProps) {
    const tType = nextProps.templateType; // Options or Cards

    this.setState({
      templateType: tType
    });

    if (!nextProps.value[tType]) { // Do not update state if it's not Options or Cards
      return false;
    }

    if (nextProps.value[tType].length > 0){
      this.setState({
        childrenDataArray: nextProps.value[tType]
      });
    }
  },

  onAddItem(event, tType) {
    event.preventDefault();

    this.setState({
      templateType: tType,
      childrenDataArray: this.state.childrenDataArray.concat([{}])
    });
  },

  onRemoveItem(event, id) {
    event.preventDefault();

    this.setState({
      childrenDataArray: this.state.childrenDataArray.filter((f, index) => index != id)
    }, () => {
      if (this.state.childrenDataArray.length === 0) {
        this.setState( this.getInitialState() );
      }
      this.updateParent();
    });
  },


  handleChildUpdate(data) {
    const tmpChildrenData = this.state.childrenDataArray;

    tmpChildrenData.map((m, index) => {
      if ( index == data.id ){
        for (var prop in data){
          if (prop != "id"){ // remove id
            m[prop] = data[prop];
          }
        }
      }
   });

    this.setState({
      childrenDataArray: tmpChildrenData
    }, () => {
      this.updateParent();
    });
  },

  updateParent() {
    this.props.componentData( {[this.state.templateType]: this.state.childrenDataArray} );
  },

  render() {
    let partial; // Show Add Options or Add Cards

    switch(this.state.templateType) {
      case 'options':
        partial = <div>
                    <a href="#" className='pull-right' onClick={e=>this.onAddItem(e,"options")}>
                      <span className='add-option'>Add Option</span>
                    </a>
                  </div>
        break;
      case 'cards':
        partial = <div>
                    <a href="#" onClick={e=>this.onAddItem(e,"cards")}>
                      <span className='add-card'>Add Card</span>
                    </a>
                  </div>
        break;
      default:
        partial = <div >
                    <a href="#" onClick={e=>this.onAddItem(e,"options")}>Add Option</a>
                    &nbsp;or&nbsp;
                    <a href="#" onClick={e=>this.onAddItem(e,"cards")}>Add Card</a>
                  </div>
        break;
    };

    return(
      <div>
        { partial }

        {this.state.childrenDataArray.map(function(childData, index){
          // Options
          if (this.state.templateType === "options"){
            return(
              <Option
                key={index}
                index={index}
                value={childData}
                updateParent={this.handleChildUpdate}
                removeItem={this.onRemoveItem}
              />
            );
          }
          // Cards
          if (this.state.templateType === "cards"){
            return(
              <Card
                key={index}
                index={index}
                value={childData}
                updateParent={this.handleChildUpdate}
                removeItem={this.onRemoveItem}
              />
            );
          }
        }.bind(this))}
      </div>
    );
  }
});
