const https = require('https');
const http = require('http');

// Função helper para fazer requisições HTTP
function makeRequest(url, options = {}) {
  return new Promise((resolve, reject) => {
    const urlObj = new URL(url);
    const isHttps = urlObj.protocol === 'https:';
    const client = isHttps ? https : http;
    
    const requestOptions = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: options.method || 'GET',
      headers: options.headers || {}
    };
    
    const req = client.request(requestOptions, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          resolve({ status: res.statusCode, data: jsonData });
        } catch (e) {
          resolve({ status: res.statusCode, data: data });
        }
      });
    });
    
    req.on('error', reject);
    
    if (options.body) {
      req.write(JSON.stringify(options.body));
    }
    
    req.end();
  });
}

/**
 * Teste específico para o endpoint confirm-delivery-by-deliverer
 */
async function testConfirmDeliveryEndpoint() {
  try {
    console.log('🧪 [TEST] Testando endpoint confirm-delivery-by-deliverer...');
    
    const baseUrl = 'https://backend-compra-pronta.onrender.com';
    
    // 1. Fazer login como entregador
    console.log('\n1. Fazendo login como entregador...');
    const loginResponse = await makeRequest(`${baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { email: 'kamilly@teste.com', senha: 'teste123' }
    });
    
    if (!loginResponse.data.token) {
      console.error('❌ Falha no login');
      return;
    }
    
    const token = loginResponse.data.token;
    const user = loginResponse.data.user;
    console.log(`✅ Login realizado: ${user.name} (isEntregador: ${user.isEntregador})`);
    
    if (!user.isEntregador) {
      console.error('❌ Usuário não é entregador');
      return;
    }
    
    // 2. Buscar um pedido para teste
    console.log('\n2. Buscando pedidos disponíveis...');
    const ordersResponse = await makeRequest(`${baseUrl}/api/delivery/orders`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    console.log(`Status da busca: ${ordersResponse.status}`);
    console.log(`Pedidos encontrados: ${ordersResponse.data.data?.length || 0}`);
    
    if (!ordersResponse.data.data || ordersResponse.data.data.length === 0) {
      console.log('⚠️  Nenhum pedido encontrado. Criando dados de teste...');
      
      // Usar um ID de pedido fictício para teste
      const testOrderId = 'test-order-id';
      const testHash = 'test-hash-123';
      
      console.log(`\n3. Testando endpoint com dados fictícios...`);
      console.log(`   - orderId: ${testOrderId}`);
      console.log(`   - delivererId: ${user.id}`);
      console.log(`   - hash: ${testHash}`);
      
      try {
        const confirmResponse = await makeRequest(
          `${baseUrl}/api/orders/${testOrderId}/confirm-delivery-by-deliverer`,
          {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            },
            body: {
              delivererId: user.id,
              hash: testHash
            }
          }
        );
        
        console.log(`✅ Resposta do endpoint: ${confirmResponse.status}`);
        console.log('Dados:', JSON.stringify(confirmResponse.data, null, 2));
        
      } catch (error) {
        console.log(`📋 Erro esperado (pedido fictício): ${error.response?.status}`);
        console.log('Mensagem:', error.response?.data?.message);
        
        if (error.response?.status === 404 && error.response?.data?.message === 'Pedido não encontrado') {
          console.log('✅ Endpoint está funcionando corretamente (erro 404 esperado)');
        } else {
          console.log('❌ Erro inesperado no endpoint');
        }
      }
      
    } else {
      // Usar pedido real
      const testOrder = ordersResponse.data.data[0];
      console.log(`\n3. Testando com pedido real: ${testOrder.id}`);
      
      try {
        const confirmResponse = await makeRequest(
          `${baseUrl}/api/orders/${testOrder.id}/confirm-delivery-by-deliverer`,
          {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${token}`,
              'Content-Type': 'application/json'
            },
            body: {
              delivererId: user.id,
              hash: 'test-hash-real'
            }
          }
        );
        
        console.log(`✅ Confirmação realizada: ${confirmResponse.status}`);
        console.log('Dados:', JSON.stringify(confirmResponse.data, null, 2));
        
      } catch (error) {
        console.log(`❌ Erro na confirmação: ${error.response?.status}`);
        console.log('Mensagem:', error.response?.data?.message);
        console.log('Dados completos:', JSON.stringify(error.response?.data, null, 2));
      }
    }
    
    // 4. Testar diferentes cenários de erro
    console.log('\n4. Testando cenários de erro...');
    
    // Teste sem token
    console.log('\n   a) Teste sem token de autenticação...');
    try {
      await makeRequest(
        `${baseUrl}/api/orders/test-id/confirm-delivery-by-deliverer`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: { delivererId: user.id, hash: 'test' }
        }
      );
    } catch (error) {
      console.log(`      - Status: ${error.response?.status} (esperado: 401)`);
      console.log(`      - Mensagem: ${error.response?.data?.message}`);
    }
    
    // Teste com dados inválidos
    console.log('\n   b) Teste com delivererId inválido...');
    try {
      await makeRequest(
        `${baseUrl}/api/orders/test-id/confirm-delivery-by-deliverer`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          },
          body: { delivererId: 'invalid-id', hash: 'test' }
        }
      );
    } catch (error) {
      console.log(`      - Status: ${error.response?.status}`);
      console.log(`      - Mensagem: ${error.response?.data?.message}`);
    }
    
  } catch (error) {
    console.error('❌ Erro no teste:', error.message);
    if (error.response) {
      console.error('   - Status:', error.response.status);
      console.error('   - Data:', error.response.data);
    }
  }
}

// Executar teste
testConfirmDeliveryEndpoint().then(() => {
  console.log('\n🏁 Teste concluído.');
}).catch(error => {
  console.error('❌ Erro fatal:', error);
});