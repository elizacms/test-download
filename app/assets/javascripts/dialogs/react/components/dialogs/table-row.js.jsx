var TableRow = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  parseResponse(response){
    var value = JSON.parse(response.response_value);

    if ( response.response_type === 'text' ) {
      return(value['response_text_input']);
    } else if ( response.response_type === 'card' ) {
      return(value['cards'][0]['text']);
    } else if ( response.response_type === 'text_with_option' ) {
      return(value['response_text_with_option_text_input']);
    } else if ( response.response_type === 'video' ) {
      return(value['response_video_text_input']);
    } else if ( response.response_type === 'question_and_answer' ){
      return(value['response_text_input']);
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
    $('.exportCSV').hide();
    this.props.sendData(this.props.data);

    $('html, body').animate({
      scrollTop: $('.dialog-form').offset().top - 50
    }, 300);
  },

  copyRow(e){
    e.preventDefault();
    $('.dialogForm').show();
    $('.dialogTable').hide();
    $('.exportCSV').hide();
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

  render() {
    let data = this.props.data;
    return (
      <tr className='dialog-data'>
        <td className='priority'>{data.priority}</td>
        <td className='response'>
          {data.responses.map(function(response, index){
            return(
              <div key={index}>
                Response [{index + 1}]:
                <br />
                Type: {response.response_type}
                <br />
                Text: {this.parseResponse(response)}
                {this.tableSeparator(data.responses.length, index)}
              </div>
            );
          }.bind(this))}
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
        <td className='present'>
          {data.present.map(function(condition, index){
            return(<div key={index}>{condition}</div>);
          })}
        </td>
        <td className='awaiting_field'>
          {data.awaiting_field.map(function(field, index){
            return(<div key={index}>{field}</div>);
          })}
        </td>
        <td>
          <a onClick={this.editRow} className='fa fa-pencil' href='#' title='Edit'></a>&nbsp;&nbsp;
          <a onClick={this.copyRow} className='fa fa-clone'  href='#' title='Copy'></a>&nbsp;&nbsp;
          <a onClick={this.deleteRow} className='fa fa-trash' rel='38' href='#' title='Delete'></a>
        </td>
      </tr>
    );
  }
});
