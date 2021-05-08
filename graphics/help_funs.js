function formatBytes(bytes, decimals) {
        if (bytes == 0) return '0 Bytes';
        var k = 1000, // 1024 for Bytes
          dm = decimals <= 0 ? 0 : decimals || 2,
          sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
          i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
      }

      function formatSeconds(seconds, decimals) {
        if (seconds == 0) {
          return '0 s';
        }
        var dm = decimals <= 0 ? 0 : decimals || 2;
        if (seconds > 3600) {
          return (seconds / 3600).toFixed(dm) + ' h';
        }
        if (seconds > 60) {
          return (seconds / 60).toFixed(dm) + ' min';
        }
        return seconds.toFixed(dm) + ' s';
      }