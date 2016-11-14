var DialogRow = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  parseRules(){
    let rule = this.props.data;
    conditions = [];

    if( rule.hasOwnProperty('unresolved') ){
      rule.unresolved.forEach(function(value, index){
        if (value !== ''){
          conditions.push( value + ' is unresolved' );
        }
      })
    }
    if( rule.hasOwnProperty('missing') ){
      rule.missing.forEach(function(value, index){
        if (value !== ''){
          conditions.push( value + ' is missing' );
        }
      })
    }
    if( rule.hasOwnProperty('present') ){
      var ary  = [];
      var ary2 = [];

      rule.present.forEach(function(value, index){
        index % 2 == 0 ? ary.push(value) : ary2.push(value);
      });

      ary.forEach(function(value, index){
        if (value !== ''){
          conditions.push( value + ' is present: "' + ary2[index] + '"' );
        }
      });
    }

    return conditions;
  },

  editRow(e){
    e.preventDefault();
    this.props.sendData(this.props.data);
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
        <td className="response">{data.response}</td>
        <td>
          {this.parseRules().map(function(condition, index){
            return(<div key={index}>{condition}</div>);
          })}
        </td>
        <td className="awaiting_field">
          {data.awaiting_field.map(function(field, index){
            return(<div key={index}>{field}</div>);
          })}
        </td>
        <td><a onClick={this.editRow} className="icon-pencil" href='#'></a></td>
        <td><a onClick={this.deleteRow} className="icon-cancel-circled" rel="38" href="#"></a></td>
      </tr>
    );
  }
});
