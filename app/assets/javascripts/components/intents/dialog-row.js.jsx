var DialogRow = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  parseRules(){
    let rule = this.props.data;
    conditions = [];

    if( rule.hasOwnProperty('unresolved') ){
      conditions.push( rule.unresolved + ' is unresolved' );
    }
    if( rule.hasOwnProperty('missing') ){
      conditions.push( rule.missing + ' is missing' );
    }
    if( rule.hasOwnProperty('present') ){
      conditions.push( rule.present[ 0 ] + ' is present: "' + rule.present[ 1 ] + '"' );
    }

    return conditions;
  },

  deleteRow(e){
    e.preventDefault();

    if ( confirm("Are you sure you'd like to delete this dialog?") ){
      this.props.deleteRow(this.props.data, this.props.itemIndex);
    }
  },

  render: function() {
    let data = this.props.data;
    return (
      <tr className="dialog-data">
        <td className="priority">{data.priority}</td>
        <td className="response">{data.responses[0].response}</td>
        <td>
          {this.parseRules().map(function(condition, index){
            return(<div key={index}>{condition}</div>);
          })}
        </td>
        <td className="awaiting_field">{data.responses[0].awaiting_field}</td>
        <td><a onClick={this.deleteRow} className="icon-cancel-circled" rel="38" href="#"></a></td>
      </tr>
    );
  }
});
