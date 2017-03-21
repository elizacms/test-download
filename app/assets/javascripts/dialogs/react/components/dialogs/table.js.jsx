var Table = React.createClass({
  propTypes: {
    title: React.PropTypes.string
  },

  render() {
    return (
      <div>
        <table className='dialogs'>
          <tbody>
            <tr>
              <th className='row4'>&nbsp;Priority</th>
              <th className='row20'>Response</th>
              <th className='row20'>Rules</th>
              <th className='row10'>Awaiting Field</th>
              <th className='row3'>Options</th>
              <th className='row3'></th>
            </tr>
            {
              this.props.data.map(function(dialog, index){
                return <TableRow
                          sendData={this.props.sendData}
                          deleteRow={this.props.deleteRow}
                          data={dialog}
                          key={index}
                          itemIndex={index}
                        >{dialog}</TableRow>;
              }.bind(this))
            }
          </tbody>
        </table>
      </div>
    );
  }
});
