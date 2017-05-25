var Template = React.createClass({
  getInitialState() {
    return {
      templateType: null,
      childrenDataArray: []
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
      }, () => {
        this.assignIds();
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
      }, () => {
        this.assignIds();
      });
    }
  },

  assignIds() {
    const tmpChildrenDataArray = this.state.childrenDataArray;

    tmpChildrenDataArray.map((childData, index) => {
      if ( !childData['msId'] ) {
        childData['msId'] = new Date().getUTCMilliseconds() + index;
      }
      return childData;
    });

    this.setState({
      childrenDataArray: tmpChildrenDataArray
    });
  },

  onAddItem(event, tType) {
    event.preventDefault();
    const uid = new Date().getUTCMilliseconds();

    this.setState({
      templateType: tType,
      childrenDataArray: this.state.childrenDataArray.concat( [{msId:uid}] )
    });
  },

  onRemoveItem(event, id) {
    event.preventDefault();

    this.setState({
      childrenDataArray: this.state.childrenDataArray.filter((c) => c.msId != id)
    }, () => {
      if (this.state.childrenDataArray.length === 0) {
        this.setState( this.getInitialState() );
      }
      this.updateParent();
    });
  },


  handleChildUpdate(data) {
    const tmpChildrenDataArray = this.state.childrenDataArray;

    tmpChildrenDataArray.map((tmpChildData, index) => {
      if (tmpChildData.msId === data.msId) {
        for (var prop in data) {
          tmpChildData[prop] = data[prop];
        }
      }
    });

    this.setState({
      childrenDataArray: tmpChildrenDataArray
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
        partial = <div >
                    <a href="#" onClick={e=>this.onAddItem(e,"options")}>Add Options</a>
                  </div>
        break;
      case 'cards':
        partial = <div>
                    <a href="#" onClick={e=>this.onAddItem(e,"cards")}>Add Cards</a>
                  </div>
        break;
      default:
        partial = <div >
                    <a href="#" onClick={e=>this.onAddItem(e,"options")}>Add Options</a>
                    &nbsp;or&nbsp;
                    <a href="#" onClick={e=>this.onAddItem(e,"cards")}>Add Cards</a>
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
