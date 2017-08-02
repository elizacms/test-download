var TableRow = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  parseResponse(obj){
    var value = JSON.parse(obj);

    if ( isNaN(value) ) {
      if ( value.hasOwnProperty('text') ) return ( value.text.substring(0, 40) + " ..." );

      return '';
    }

    switch ( value ) {
      case 1:
        return("Text w/ Options");
      case 2:
        return("Video");
      case 3:
        return("Cards");
      case 4:
        return("Questions & Answers");
      default:
        return("Text");
        break;
    }
  },

  showLoneEV(entity_values){
    if (entity_values.length === 2 && entity_values[1] === ''){
      return(
        <div>
          {"[('" + entity_values[0] + "')]"}
        </div>
      );
    }
  },

  tableSeparator(length, index){
    if (length > 1 && index + 1 !== length){
      return(<hr className='table-response-separator' />);
    }
  },

  editRow(e){
    e.preventDefault();
    $('.dialogForm').show();
    $('.dialogTable').hide();
    $('.dialogHeader').hide();
    this.props.sendData(this.props.data);

    $('html, body').animate({
      scrollTop: $('.dialog-form').offset().top - 50
    }, 300);
  },

  copyRow(e){
    e.preventDefault();
    $('.dialogForm').show();
    $('.dialogTable').hide();
    $('.dialogHeader').hide();
    this.props.copyData(this.props.data);

    $('html, body').animate({
      scrollTop: $('.dialog-form').offset().top - 50
    }, 300);
  },

  deleteRow(e){
    e.preventDefault();

    if ( confirm("Are you sure you'd like to delete this dialog?") ){
      this.props.deleteRow(this.props.data, this.props.itemIndex);
    }
  },

  displayControlOptions(){
    if (!this.props.locked) {
      return(
        <div>
          <a onClick={this.editRow} className='fa fa-pencil control-icon' href='#' title='Edit'></a>
          <a onClick={this.copyRow} className='fa fa-clone  control-icon' href='#' title='Copy'></a>
          <a onClick={this.deleteRow} className='fa fa-trash control-icon' rel='38' href='#' title='Delete'></a>
        </div>
      );
    }
  },

  render() {
    let data = this.props.data;

    return (
      <tr className='dialog-data'>
        <td className='priority'>{data.priority}</td>
        <td className='response'>
          {/* Display response type or intent reference */}
          {data.responses_attributes.map(function(response, index){
            return(
              <div key={index} className="line-spacing">
                Type: {this.parseResponse(response.response_type)}
                <br />
                {this.parseResponse(response.response_value)}
                {this.tableSeparator(data.responses_attributes.length, index)}
              </div>
            );
          }.bind(this))}

          Intent: { data.intent_reference }
        </td>
        <td className='unresolved'>
          {data.unresolved.map(function(condition, index){
            return(<div key={index}>{condition}</div>);
          })}
        </td>
        <td className='missing'>
          {data.missing.map(function(condition, index){
            return(<div key={index}>{condition}</div>);
          })}
        </td>
        <td className='awaiting_field'>
          {data.awaiting_field.map(function(field, index){
            return(<div key={index}>{field}</div>);
          })}
        </td>
        <td className='entity_values'>
          {data.entity_values.length === 2 && data.entity_values[1] === '' ? this.showLoneEV(data.entity_values) : data.entity_values.map(function(value, index){
              return(
                <div key={index}>
                  {index % 2 === 0 ? "[('" + value + "'," : "'" + value + "')]"}
                </div>
              );
          })}
        </td>
        <td className='present'>
          {data.present.map(function(condition, index){
            return(<div key={index}>{condition}</div>);
          })}
        </td>
        <td>
          {this.displayControlOptions()}
        </td>
      </tr>
    );
  }
});
